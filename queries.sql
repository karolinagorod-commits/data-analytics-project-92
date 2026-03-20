SELECT COUNT(customer_id) AS customers_count
FROM customers;

SELECT
    -- объединяем имя и фамилию, без лишних пробелов
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    -- количество сделок
    COUNT(*) AS operations,
    -- считаем выручку продавца за всё время
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
-- соединяем таблицы
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
GROUP BY seller
ORDER BY income DESC
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
    s.seller,
    FLOOR(s.average) AS average_income
FROM seller_avg AS s
-- выборка продавцов с меньшей средней выручкой
WHERE s.average < (SELECT
    AVG(p.price * sa.quantity)
FROM sales AS sa
INNER JOIN products AS p
    ON sa.product_id = p.product_id)
ORDER BY s.average ASC;

SELECT
    TRIM(e.first_name) || ' ' || TRIM(e.last_name) AS seller,
    -- преобразовываем дату в день недели
    TRIM(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
    -- считаем выручку по дням
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
GROUP BY
    seller,
    day_of_week,
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY EXTRACT(ISODOW FROM s.sale_date) ASC, seller ASC;

SELECT
    -- age_category с тремя диапазонами возрастов
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        WHEN age > 40 THEN '40+'
    END AS age_category,
    -- считаем количество человек в каждом диапазоне
    COUNT(*) AS age_count
FROM customers
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
    s.sale_date,
    -- объединяем имя и фамилию
    TRIM(c.first_name) || ' ' || TRIM(c.last_name) AS customer,
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
