SELECT COUNT(customer_id) AS customers_count
FROM customers;

WITH tab AS (
    SELECT
        FLOOR(SUM(p.price * s.quantity)) AS income, -- считаем выручку продавца за всё время
        s.sales_person_id,
        COUNT(*) AS operations, -- количество сделок
        TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller -- объединяем имя и фамилию, без лишних пробелов
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id -- соединяем таблицы
    GROUP BY s.sales_person_id, seller
)

SELECT
    t.seller,
    t.operations,
    t.income
FROM tab AS t
ORDER BY t.income DESC
LIMIT 10;

WITH seller_avg AS (
    SELECT
        TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
        AVG(p.price * s.quantity) AS average -- считаем среднюю выручку за сделку
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
    GROUP BY seller
)

SELECT
    seller,
    FLOOR(average) AS average_income
FROM seller_avg
WHERE average < (SELECT AVG(average) FROM seller_avg) -- условие для выборки продавцов с меньшей средней выручкой
ORDER BY average ASC;

WITH table AS (
    SELECT
        TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
        TRIM(TO_CHAR(s.sale_date, 'day')) AS day_of_week, -- преобразовываем дату в день недели
        EXTRACT(ISODOW FROM s.sale_date) AS day_number, -- задаём порядковый номер каждому дню
        FLOOR(SUM(p.price * s.quantity)) AS income -- считаем выручку по дням
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
    GROUP BY seller, day_of_week, day_number
)

SELECT -- итоговый запрос
    t.seller,
    t.day_of_week,
    t.income
FROM table AS t
ORDER BY day_number, seller ASC;

WITH age_groups AS (
    SELECT
        customer_id,
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category -- создаём столбец age_category с тремя диапазонами возрастов
    FROM customers
)

SELECT
    age_category,
    COUNT(*) AS age_count -- считаем количество человек в каждом диапазоне
FROM age_groups
GROUP BY age_category
ORDER BY age_category ASC;

SELECT
    TO_CHAR(s.sale_date, 'yyyy-mm') AS selling_month, -- получаем из даты только год и месяц
    COUNT(DISTINCT s.customer_id) AS total_customers, -- считаем количество уникальных покупателей
    FLOOR(SUM(p.price * s.quantity)) AS income -- считаем выручку
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;

SELECT DISTINCT ON (c.customer_id) -- отсеиваем дубли покупателей
    TRIM(c.first_name) || ' ' || TRIM(c.last_name) AS customer, -- объединяем имя и фамилию
    s.sale_date,
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN customers AS c ON s.customer_id = c.customer_id -- соединяем все таблицы
WHERE p.price = 0 -- задаём условие с акционной ценой
ORDER BY c.customer_id, s.sale_date ASC; -- сортируем по id и первой дате покупки
