/1. 
Выведите на экран список уникальных названий городов доставки, начинающихся на San, в которые оформили хотя бы один заказ после 16 июля 1996 года. 
Отсортируйте таблицу в лексикографическом порядке по убыванию./
select distinct(ship_city)
from northwind.orders
where ship_city like 'San%'
and order_date > '16-07-1996'

  
/2.
Используя таблицу с заказами, выведите количество уникальных идентификаторов клиентов (поле customer_id), которые совершили хотя бы один заказ./
select 
    count(distinct(customer_id))
from northwind.orders
where order_id >=1

  
/3. 
Для всех товаров, у которых указан поставщик, выведите пары с названием товара и названием компании-поставщика этого товара./
select  product_name(q)
    ,company_name(w) -- напишите ваш запрос здесь
from northwind.products as q
left join northwind.suppliers as w
on supplier_id(q)= supplier_id(w)
where supplier_id(q) is not null

  
/4. 
Выведите среднюю цену товаров каждой категории из таблицы products. Округлите среднее до двух знаков после запятой. /
SELECT 
    category_id, 
    ROUND(AVG(unit_price::numeric), 2) AS avg_unit_price 
FROM northwind.products 
GROUP BY category_id

  
/5. 
Выведите уникальные названия всех стран, в которые было отправлено более 10 заказов. Отсортируйте вывод по названию страны в лексикографическом порядке по убыванию./
select distinct(ship_country)
from northwind.orders
group by ship_country
having count(distinct(order_id))> 10
order by ship_country DESC

  
/6. 
Отберите страны, в которых оформили больше 30 заказов, и выведите количество заказов в этих странах. Результаты отсортируйте по названию страны в лексикографическом порядке. /
select
    ship_country
    ,count(distinct(order_id)) as count
from northwind.orders
group by ship_country
having count(distinct(order_id))>30
order by ship_country

  
/7. 
Выведите на экран названия товаров с ценой выше среднего среди всех представленных позиций в таблице./
select product_name   
from northwind.products
where unit_price > (select avg(unit_price) from northwind.products)

  
/8.
Выведите названия товаров с ценой ниже средней среди всех представленных товаров или равной ей./
select product_name
from northwind.products
where unit_price <= (select avg(unit_price) from northwind.products)

  
/9.
Выведите на экран идентификаторы заказов и для каждого из них — его суммарную стоимость с учётом всех товаров, включённых в заказ, и их количества, но без учёта скидки. 
Не округляйте получившиеся значения. /
select q.order_id
    , sum(w.unit_price * w.quantity) 
from northwind.orders as q 
left join
    (select unit_price
        ,order_id
        ,quantity
    from northwind.order_details
    ) as w 
on q.order_id= w.order_id
group by q.order_id


/10. 
Выведите на экран идентификаторы заказов и для каждого из них — суммарную стоимость заказа с учётом всех заказанных товаров и их количества с учётом скидки. 
Получившиеся значения округлите до ближайшего целого числа. Отсортируйте выдачу по возрастанию идентификаторов заказов./
select 
    q.order_id
    ,round(sum (w.unit_price * w.quantity * (1- w.discount))) as order_total_with_discount
from northwind.orders as q left join (
    select order_id
        ,product_id
        ,unit_price
        ,quantity
        ,discount
    from northwind.order_details
) as w
on q.order_id = w.order_id
group by q.order_id
order by q.order_id


/11.
Выведите информацию о каждом товаре:
- его идентификатор из таблицы с товарами;
- его название из таблицы с товарами;
- название его категории из таблицы категорий;
- описание его категории из таблицы категорий.
Таблицу отсортируйте по возрастанию идентификаторов товаров./
select q.product_id
    ,q.product_name
    ,w.category_name
    ,w.description
from northwind.products as q left join
    (
        select 
        category_id
        ,category_name
        ,description
    from northwind.categories
    ) as w
on q.category_id = w.category_id
order by q.product_id


/12. 
Для каждого месяца каждого года посчитайте уникальных пользователей, оформивших хотя бы один заказ в этот месяц. Значение месяца приведите к типу date./
SELECT
    DATE_TRUNC('month', order_date)::date AS month
    ,
    COUNT(DISTINCT customer_id) AS unique_users
FROM northwind.orders
GROUP BY DATE_TRUNC('month', order_date)::date

  
/13.
Для каждого года из таблицы заказов посчитайте суммарную выручку с продаж за этот год. Используйте детальную информацию о заказах. 
Не забудьте учесть скидку (поле discount) на товар. Результаты отсортируйте по убыванию значения выручки./
select extract('year' from q.order_date) year_sum
    ,sum(w.total_price) as total_price
from northwind.orders as q left join 
    (
    select 
        order_id
        , sum(unit_price * quantity * (1-discount)) as total_price
    from northwind.order_details
    group by order_id
    ) as w 
on q.order_id = w.order_id
group by  year_sum
order by total_price DESC


/14. Выведите названия компаний-покупателей, которые совершили не менее двух заказов в 1996 году. 
Отсортируйте вывод по полю с названиями компаний в лексикографическом порядке по возрастанию./
select 
    company_name
from northwind.customers 
where customer_id in
    (
        select 

             customer_id
             --,count(distinct(order_id)) as count_ord
        from northwind.orders
        where extract(year from order_date)= 1996
        group by customer_id
        having count(distinct(order_id)) >= 2 
    ) 
order by company_name

/15.
Выведите названия компаний-покупателей, которые совершили более пяти заказов в 1997 году. Отсортируйте вывод по полю с названиями компаний в лексикографическом порядке по убыванию./
select company_name
from northwind.customers
where customer_id in (
    select customer_id
    from northwind.orders
    where extract(year from order_date) =1997
    group by customer_id
    having count(distinct(order_id)) >5 
)
order by company_name  desc


/16.
Выведите среднее количество заказов компаний-покупателей за период с 1 января по 1 июля 1998 года. 
Округлите среднее до ближайшего целого числа. В расчётах учитывайте только те компании, которые совершили более семи покупок за всё время, а не только за указанный период./
select round(avg(purch))
from (
    select count(distinct(order_id)) as purch
        --order_date
    from northwind.orders
    where customer_id in (
        select customer_id
        from northwind.orders
        group by customer_id
        having count(distinct(order_id)) > 7)
    and order_date::date > '1998-01-01' and order_date::date < '1998-07-01'
    group by customer_id) as q


/17.
Выведите на экран названия компаний-покупателей, которые хотя бы раз оформили более одного заказа в день. Для подсчёта заказов используйте поле order_date. 
Отсортируйте названия компаний в лексикографическом порядке по возрастанию./
select company_name
from northwind.customers
where customer_id in 
(
    select customer_id
        --,order_date,
        --count(order_id)
    from northwind.orders
    group by customer_id, order_date
    having count(order_id) > 1)
order by company_name


/18. 
Выведите города, в которые отправляли заказы не менее 10 раз. Названия городов отсортируйте в лексикографическом порядке по убыванию./
select ship_city
from northwind.orders
group by ship_city
having count(order_id) >= 10
order by ship_city desc



