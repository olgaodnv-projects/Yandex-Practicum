/1.
  Выведите среднюю себестоимость товара каждого класса (L — эконом, M — стандарт, H — премиум). Значение себестоимости округлите до одного знака после запятой. 
  При подсчёте исключите строки, в которых класс товара не указан, то есть вместо значения в них стоит NULL. 
  Выдачу отсортируйте по возрастанию средней себестоимости./
select
    class
    ,round(avg(standard_cost), 1) as avg_cost
FROM adventure.product
where class is not null
group by class
order by round(avg(standard_cost), 1)


/2.
Отберите товары серебряного (англ. Silver) цвета, которые стали продаваться начиная с 2011 года, и выведите их идентификаторы и даты старта продаж в формате timestamp./
Select
    product_id
    , sell_start_date::timestamp 
From adventure.product
where extract (year from sell_start_date) >= 2011
and color = 'Silver'


/3.
Отберите товары красного (англ. Red) цвета, которые стали продаваться начиная с 2012 года, и выведите их идентификаторы и даты старта продаж в формате timestamp./
select product_id
    , sell_start_date::timestamp
from adventure.product 
where extract(year from sell_start_date) >= 2012
and color = 'Red'


/4.
Выведите название компании каждого поставщика и город, в котором он находится. Отсортируйте таблицу по названию компании в лексикографическом порядке по возрастанию./
select vv.name
    ,q.city
from adventure.vendor  vv join (
    select 
        v.vendor_id
        ,v.address_id
        ,a.city
    from adventure.vendor_address v join adventure.address a 
    on v.address_id =a.address_id)as q
on vv.vendor_id = q.vendor_id
order by vv.name


/5.
Выведите всю информацию о заказах из таблицы purchase_order_header, оформленных с 2012 по 2013 год (поле order_date). 
Отсортируйте вывод по возрастанию идентификатора заказа./
select *
from adventure.purchase_order_header
where extract('year' from order_date) in (2012, 2013)
order by purchase_order_id


/6.
Выведите среднее количество доступных часов отпуска для сотрудников в разном семейном положении. 
Округлите среднее до двух знаков после запятой. Отсортируйте таблицу по возрастанию посчитанных средних значений./
Select 
    marital_status
    ,round(avg(vacation_hours), 2) as avg_vacation_hours
from adventure.employee
group by  marital_status
order by round(avg(vacation_hours), 2)


/7.
Для каждого месяца c мая по август 2012 года найдите количество совершённых заказов. 
Выведите первое число каждого месяца и количество заказов в этот месяц. Отсортируйте выдачу по возрастанию дат./
select 
    date_trunc('month', order_date::timestamp)::date as month_p
    ,count(distinct purchase_order_id) 
from adventure.purchase_order_header 
where date_trunc('month', order_date::timestamp)::date >= '2012-05-01'
and date_trunc('month', order_date::timestamp)::date <= '2012-08-01'
group by date_trunc('month', order_date)
order by month_p


/8.
Из таблицы purchase_order_header выведите идентификатор заказа и дату отгрузки для заказов с наименьшей стоимостью доставки (поле ship_base). 
Отсортируйте выдачу по возрастанию даты отгрузки. Используйте подзапросы./
Select q.purchase_order_id
    ,q. ship_date
from adventure.purchase_order_header q join adventure.ship_method w
on q.ship_method_id = w.ship_method_id
where w.ship_base = (select 
        min(ship_base) as min_ship_base
    from  adventure.ship_method )


/9.
Отберите заказы, цена доставки которых (поле ship_base) не была ни наименьшей, ни наибольшей. 
Из таблицы purchase_order_header выведите идентификатор и дату отгрузки для отобранных заказов. 
Отсортируйте выдачу по возрастанию даты отгрузки. Используйте подзапросы.
select
    q.purchase_order_id
    ,q.ship_date
from adventure.purchase_order_header q join adventure.ship_method  w 
on q.ship_method_id = w.ship_method_id
where w.ship_method_id in (select ship_method_id
            from adventure.ship_method 
            where ship_base not in (select min(ship_base) from adventure.ship_method)
            and ship_base not in (select max(ship_base) from adventure.ship_method))


/9.
Выведите идентификаторы заказов из таблицы purchase_order_header c максимальным интервалом в днях между датой оформления заказа и датой отгрузки./
select purchase_order_id
from adventure.purchase_order_header
where (ship_date - order_date) =(
    select
        max(ship_date - order_date)
    from adventure.purchase_order_header)


/10.
Отберите отклонённые заказы из таблицы purchase_order_header и посчитайте, на какую сумму был сделан каждый из них. 
Чтобы найти сумму заказа, используйте цену за единицу товара (поле unit_price) и количество единиц товара в заказе (поле order_qty).
Округлите суммарные значения до двух знаков после запятой. Отсортируйте выдачу по возрастанию суммы заказа. Заказы на одинаковую сумму отсортируйте по возрастанию идентификаторов.
SELECT  poh.purchase_order_id AS purchase_order_id,
        ROUND(SUM(pod.unit_price * pod.order_qty), 2) AS total
FROM  adventure.purchase_order_header AS poh
INNER JOIN adventure.purchase_order_detail AS pod ON poh.purchase_order_id = pod.purchase_order_id
WHERE poh.status = 3 
GROUP BY poh.purchase_order_id
ORDER BY total, purchase_order_id;


/11.
Выведите названия компаний-поставщиков и полный адрес их сайтов, если он заканчивается на .com/. 
Компании с другими адресами не должны попасть в выдачу. Отсортируйте итоговую таблицу по имени поставщика в лексикографическом порядке по возрастанию./
select 
    name
    , purchasing_web_service_url
from adventure.vendor
where purchasing_web_service_url like '%.com/'
order by name 


/12.
Выведите названия компаний-поставщиков и города, в котором находится каждая из компаний. 
Отобразите информацию о компаниях с адресами сайтов, которые заканчиваются на .com/. 
Отсортируйте итоговую таблицу по имени поставщика в лексикографическом порядке по убыванию./
with
q as (select
    va.vendor_id
    ,a.city
from adventure.vendor_address as va  
join adventure.address as a 
on va.address_id = a.address_id
)

select 
    v.name
    ,q.city
from adventure.vendor v join q on v.vendor_id = q.vendor_id
where purchasing_web_service_url like '%.com/'
order by name desc


/13.
Отберите поставщиков с кредитным рейтингом выше 3, услугами которых до сих пор пользуются. 
Выведите название компании и улицу (поле addressline1), на которой компания находится. 
Отсортируйте выдачу по названию компании в лексикографическим порядке по возрастанию./
select 
    name
    ,q.addressline1
from adventure.vendor v join (
    select 
        a.addressline1
        ,va.vendor_id
    from adventure.vendor_address va join adventure.address a 
    on va.address_id = a.address_id) as q
on v.vendor_id= q.vendor_id
where credit_rating > 3 
and is_active = True
order by name


/14.
Из таблицы purchase_order_header выведите несколько полей:
идентификатор заказа;
идентификатором сотрудника, оформившего заказ;
дата оформления заказа (поле order_date).
Добавьте поле с датой предыдущего заказа, который оформил сотрудник. Если предыдущего заказа нет, используйте значение NULL./
select
    purchase_order_id
    ,employee_id
    ,order_date
    , lag(order_date) over (partition by employee_id order by order_date ) as previous_order
from adventure.purchase_order_header


/15. 
Из таблицы purchase_order_header выведите идентификаторы заказов с максимальным интервалом между текущим и предыдущим заказами, которые были созданы одним сотрудником./
with 
q as(
select
    purchase_order_id
    ,order_date - lag(order_date)over (partition by employee_id order by order_date) AS  time_to_second
from adventure.purchase_order_header)

, w as (
    select 
    max(time) as max_time from (select 
    order_date - lag(order_date)over (partition by employee_id order by order_date)  as time
    from adventure.purchase_order_header) as e
)

select purchase_order_id
from q  
where time_to_second = (select max(time) as max_time from (select 
    order_date - lag(order_date)over (partition by employee_id order by order_date) as time
    from adventure.purchase_order_header) as e)
order by purchase_order_id


/16.
Напишите запрос, который выведет идентификаторы и даты заказов (поле order_date) из таблицы purchase_order_header. 
Отдельным полем отобразите суммарную стоимость заказов за текущий месяц. 
Стоимость заказа можно взять из поля subtotal./
select
    poh.purchase_order_id
    ,poh.order_date
    ,q.total
from adventure.purchase_order_header  as poh 
join(
    select -- суммарная стоимость заказов за месц
        SUM(subtotal::DECIMAL(20, 6)) AS total 
        ,date_trunc('month', order_date::timestamp) as order_date
    from adventure.purchase_order_header
    group by date_trunc('month', order_date::timestamp)) as q
on date_trunc('month', poh.order_date::timestamp) = date_trunc('month', q.order_date::timestamp)


/17.
Из таблицы purchase_order_header выведите несколько полей:
- идентификатор сотрудника;
- идентификатор десятого по счёту заказа, который оформил сотрудник;
- дата (поле order_date) десятого по счёту заказа сотрудника.
Отсортируйте таблицу по возрастанию идентификаторов сотрудников./
with
a as (
select
    employee_id
    ,purchase_order_id
    ,order_date
    ,row_number () over (partition by employee_id order by order_date) as ord_number
from adventure.purchase_order_header
)

select
    employee_id
    ,purchase_order_id
    ,order_date
from a 
where ord_number=10
order by employee_id


/18.Из таблицы purchase_order_header выведите несколько полей:
- идентификатор сотрудника;
- идентификатор второго по счёту заказа, который оформил сотрудник;
- дата (поле order_date) второго по счёту заказа сотрудника.
Отсортируйте таблицу по возрастанию идентификаторов сотрудников./
select 
    employee_id
    ,purchase_order_id
    ,order_date
from (
    select
        employee_id
        ,purchase_order_id
        ,order_date
        ,row_number() over (partition by employee_id order by order_date)
from adventure.purchase_order_header) as q
where row_number= 2
order by employee_id


/19.
Используя таблицу purchase_order_header, выведите несколько полей:
- идентификатор сотрудника employee_id;
- дата оформления заказа order_date;
- сумма заказа subtotal;
- сумма заказа с накоплением для каждого сотрудника, отсортированная по возрастанию даты заказа.
Значения двух последних полей округлите до двух знаков после запятой./
select
    employee_id
    ,order_date
    ,round(subtotal, 2)
    ,round( SUM(subtotal) over (partition by employee_id order by order_date),2)
from adventure.purchase_order_header


/20.
Используя таблицу purchase_order_header, выведите несколько полей:
дата заказа (поле order_date), усечённая до первого числа месяца и приведённая к типу date;
общая сумма заказа subtotal;
сумма заказа с накоплением по месяцам, отсортированная по возрастанию месяца оформления заказа./
select
    date_trunc('month', order_date):: date as month_date
    ,subtotal
    ,sum(subtotal) over (order by date_trunc('month', order_date):: date) as cum_sum
from adventure.purchase_order_header

/21. Пользуясь таблицей purchase_order_header, выведите поля с идентификатором заказа, суммой заказа (поле subtotal) и минимальным значением суммы среди текущей и двадцати следующих записей. 
Значения последних двух полей округлите до одного знака после запятой./
SELECT
    purchase_order_id
    ,round(subtotal, 1)
    ,ROUND(MIN(subtotal) OVER (ROWS BETWEEN CURRENT ROW AND 20 FOLLOWING), 1)
from adventure.purchase_order_header

/22.
Пользуясь таблицей purchase_order_header, выведите поля с идентификатором заказа, суммой заказа (поле subtotal) и максимальным значением суммы среди пяти предыдущих записей и текущей. 
Округлять значения не нужно./
select
    purchase_order_id
    ,subtotal
    ,max(subtotal) over (ROWS BETWEEN 5 Preceding AND CURRENT ROW) as max_subtotal
    --MIN(subtotal) OVER (ROWS BETWEEN CURRENT ROW AND 20 FOLLOWING)
from adventure.purchase_order_header


/23.
Выведите идентификаторы и названия товаров серебряного (англ. Silver) цвета, которые относятся к категории горных велосипедов (англ. Mountain Bikes). 
Отсортируйте выдачу по возрастанию идентификаторов товаров./
select
    product_id
    ,name
from adventure.product 
where color = 'Silver'
and product_subcategory_id in(
        select product_subcategory_id
        from adventure.product_subcategory
        where name = 'Mountain Bikes')


/24.
Выведите идентификаторы и названия товаров красного (англ. Red) цвета, которые относятся к категории дорожных велосипедов (англ. Road Bikes). 
Отсортируйте выдачу по возрастанию идентификаторов товаров./
select
    product_id
    ,name
from adventure.product 
where color = 'Red'
and product_subcategory_id in(
        select product_subcategory_id
        from adventure.product_subcategory
        where name = 'Road Bikes')
order by product_id

/25.
Используя таблицу purchase_order_header, вычислите, сколько денег потратили клиенты на заказы в каждом месяце 2012 года. 
В итоговую таблицу войдут два поля: название месяца (в нижнем регистре) и суммарные траты за месяц, округлённые до двух знаков после запятой. 
Отсортируйте результаты по убыванию числа трат./
SELECT 
     ('{январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь}'::text[])[EXTRACT(MONTH FROM order_date)] AS month
    ,round(sum (subtotal), 2) as total
from adventure.purchase_order_header
where extract(year from order_date) = 2012
group by EXTRACT(MONTH FROM order_date)
order by total desc


/26.
Используя таблицу purchase_order_header, вычислите, сколько денег потратили клиенты (поле subtotal) на заказы в каждом квартале 2012 года. 
В итоговую таблицу войдут два поля: название квартала (первый квартал, второй квартал и т. д.) и суммарные траты за квартал, округлённые до двух знаков после запятой. 
Отсортируйте результаты по возрастанию числа трат./
select 
    ('{первый квартал, второй квартал, третий квартал, четвёртый квартал}'::text[])[extract(quarter from order_date)] as quarter
    , round(sum(subtotal),2) as total
from adventure.purchase_order_header
where extract (year from order_date) =2012
group by extract(quarter from order_date)
order by total


/27.
Используя таблицу purchase_order_header, для каждого квартала 2012 года рассчитайте, на сколько процентов изменились траты клиентов на заказы в текущем квартале по сравнению с предыдущим.
Используя таблицу purchase_order_header, выведите три поля: 
Номер квартала (1, 2, 3, 4) 2012 года.
Общая сумма трат за текущий квартал.
Вещественное число (положительное или отрицательное), которое обозначает, на сколько процентов изменилась сумма трат в текущем квартале по сравнению с предыдущим. Для расчётов используйте поле subtotal.
Значения двух последних полей округлите до двух знаков после запятой./
select  
    EXTRACT (QUARTER FROM ORDER_DATE) AS  QUARTER
    ,ROUND( SUM(subtotal),2) as total
    ,ROUND(((ROUND(SUM(subtotal), 2)::numeric / LAG(ROUND(SUM(subtotal), 2), 1, NULL) OVER (ORDER BY EXTRACT(QUARTER FROM order_date)))-1)*100, 2) AS percentage_change
FROM adventure.purchase_order_header
WHERE EXTRACT(YEAR FROM order_date) = '2012'
GROUP BY EXTRACT(QUARTER FROM order_date)
ORDER BY quarter;


/28.
Используя таблицу purchase_order_detail и ранжирующую оконную функцию, посчитайте заказы, в которых было 3 товара и более./
SELECT COUNT(row_number)
FROM (SELECT  purchase_order_id, 
              product_id,
              ROW_NUMBER() OVER (PARTITION BY purchase_order_id )
      FROM adventure.purchase_order_detail
     ) AS t1
WHERE row_number = 3;


/29.
Используя таблицу purchase_order_detail и ранжирующую оконную функцию, посчитайте заказы, в которых было от 20 товаров по цене 37 долларов за единицу (поле unit_price) или дороже./
select count(unit)
from (
    select
        row_number() over (partition by purchase_order_id)  as unit
    from adventure.purchase_order_detail
    where unit_price >= 37) as q
where unit = 20

/30.
Пользуясь таблицей purchase_order_header, посчитайте, сколько денег тратили клиенты на заказы каждый год, а также разницу в тратах между следующим и текущим годами. Разница должна показывать, на сколько траты следующего года отличаются от текущего. В случае, если данных по следующему году нет, используйте NULL.
Выгрузите поля:
год оформления заказа (поле order_date), приведённый к типу date;
траты за текущий год (используя поле subtotal);
разница в тратах между следующим и текущим годами./
select 
    year
    ,year_expenditure
    ,lead(year_expenditure) over (order by year) -  year_expenditure as year_diff
from (
select 
     date_trunc( 'year' , order_date) ::date  as year
     , sum (subtotal) over (partition by date_trunc( 'year' , order_date) ::date) as year_expenditure   
from adventure.purchase_order_header) as q
group by year, year_expenditure
order by year

/31.
Отберите товары, которые последний раз поставляли в 2013 году или позже. Выведите названия этих товаров и даты их последней поставки. Отсортируйте выдачу по возрастанию дат./
with 
q as (
select
     product_id
     , last_receipt_date
from adventure.product_vendor
where extract (year from last_receipt_date) >=2013)
 
select name,
    last_receipt_date
from adventure.product w join q
on q.product_id = w. product_id
order by last_receipt_date


/32.
Отберите товары, которые последний раз поставляли в 2012 году или позже. Для отобранных товаров выведите:
Название товара.
Сумму, которую потратили на заказ этого товара за всё время, представленное в данных. Для расчёта трат используйте поля unit_price и order_qty из таблицы purchase_order_detail.
Отсортируйте результаты по возрастанию суммы трат./
SELECT p.name,
       SUM(pod.unit_price * pod.order_qty) AS total
FROM adventure.product AS p
JOIN adventure.purchase_order_detail AS pod ON p.product_id=pod.product_id
WHERE p.product_id IN (SELECT product_id
                       FROM adventure.product_vendor
                       WHERE EXTRACT(YEAR FROM last_receipt_date) >= 2012)
GROUP BY p.name
ORDER BY total;

