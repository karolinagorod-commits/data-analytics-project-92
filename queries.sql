select count(customer_id) as customers_count
from customers;

with tab as
(select floor(sum(p.price * s.quantity)) as income, -- считаем выручку продавца за всё время
s.sales_person_id, 
count(*) as operations, -- количество сделок
trim(e.first_name) ||' '|| trim(e.last_name) as seller -- объединяем имя и фамилию, без лишних пробелов
from sales s 
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id -- соединяем таблицы 
group by s.sales_person_id, seller)
select t.seller, t.operations, t.income -- итоговый запрос
from tab t
order by income desc
limit 10;

with tab as (
select 
trim(e.first_name) ||' '|| trim(e.last_name) as seller,
avg(p.price * s.quantity) as average -- считаем среднюю выручку за сделку
from sales s 
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
group by seller)
select seller, floor(average) as average_income
from tab
where average < (select avg(average) from tab) -- условие для выборки продавцов с меньшей средней выручкой
order by average asc;

with tab as(
select 
trim(e.first_name) ||' '|| trim(e.last_name) as seller,
trim(to_char(s.sale_date, 'day')) as day_of_week, -- преобразовываем дату в день недели
extract(isodow from s.sale_date) as day_number, -- задаём порядковый номер каждому дню
floor(sum(p.price * s.quantity)) as income -- считаем выручку по дням
from sales s 
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
group by seller, day_of_week, day_number)
select t.seller, t.day_of_week, t.income -- итоговый запрос
from tab t
order by day_number, seller asc;

with age as
(select customer_id,
case
when age between 16 and 25 then '16-25'
when age between 26 and 40 then '26-40'
when age > 40 then '40+'
end as age_category -- создаём столбец age_category с тремя диапазонами возрастов
from customers
)
select age_category, count(*) as age_count -- считаем количество человек в каждом диапазоне
from age
group by age_category
order by age_category asc;

select
to_char(s.sale_date, 'yyyy-mm') as selling_month, -- получаем из даты только год и месяц
count(distinct s.customer_id) as total_customers, -- считаем количество уникальных покупателей
floor(sum(p.price * s.quantity)) as income -- считаем выручку
from sales s
inner join products p on s.product_id = p.product_id
group by selling_month
order by selling_month asc;

select
distinct on (c.customer_id) -- отсеиваем дубли покупателей
trim(c.first_name) ||' '|| trim(c.last_name) as customer, -- объединяем имя и фамилию
s.sale_date,
trim(e.first_name) ||' '|| trim(e.last_name) as seller
from sales s
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
inner join customers c on s.customer_id = c.customer_id -- соединяем все таблицы
where price = 0 -- задаём условие с акционной ценой
order by c.customer_id, sale_date asc; -- сортируем по id и первой дате покупки