SELECT COUNT(customer_id) AS customers_count
FROM customers;

WITH tab AS (
    SELECT
        s.sales_person_id,
        -- объединяем имя и фамилию, без лишних пробелов
        TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
        -- количество сделок
        COUNT(*) AS operations,
        -- считаем выручку продавца за всё время
        FLOOR(SUM(p.price * s.quantity)) AS income
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
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
        -- считаем среднюю выручку за сделку
        AVG(p.price * s.quantity) AS average
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
    GROUP BY seller
)

SELECT
    seller,
    FLOOR(average) AS average_income
FROM seller_avg
-- выборка продавцов с меньшей средней выручкой
WHERE average < (SELECT AVG(average) FROM seller_avg)
ORDER BY average ASC;

WITH day_sales AS (
    SELECT
        TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
        -- преобразовываем дату в день недели
        TRIM(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
        -- задаём порядковый номер каждому дню
        EXTRACT(ISODOW FROM s.sale_date) AS day_number,
        -- считаем выручку по дням
        FLOOR(SUM(p.price * s.quantity)) AS income
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
    GROUP BY seller, day_of_week, day_number
)

-- итоговый запрос
SELECT
    d.seller,
    d.day_of_week,
    d.income
FROM day_sales AS d
ORDER BY day_number ASC, seller ASC;

WITH age_groups AS (
    SELECT
        customer_id,
        -- создаём столбец age_category с тремя диапазонами возрастов
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM customers
)

SELECT
    age_category,
    -- считаем количество человек в каждом диапазоне
    COUNT(*) AS age_count
FROM age_groups
GROUP BY age_category
ORDER BY age_category ASC;

SELECT
    -- получаем из даты только год и месяц
    TO_CHAR(s.sale_date, 'yyyy-mm') AS selling_month,
    -- считаем количество уникальных покупателей
    COUNT(DISTINCT s.customer_id) AS total_customers,
    -- считаем выручку
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month ASC;

-- отсеиваем дубли покупателей
SELECT DISTINCT ON (c.customer_id)
    -- объединяем имя и фамилию
    TRIM(c.first_name) || ' ' || TRIM(c.last_name) AS customer,
    s.sale_date,
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
-- соединяем все таблицы
INNER JOIN customers AS c ON s.customer_id = c.customer_id
-- задаём условие с акционной ценой
WHERE p.price = 0
-- сортируем по id и первой дате покупки
ORDER BY c.customer_id ASC, s.sale_date ASC;
