/1.
Выведите общую сумму просмотров у постов, опубликованных в каждый месяц 2008 года. 
Если данных за какой-либо месяц в базе нет, такой месяц можно пропустить. 
Результат отсортируйте по убыванию общего количества просмотров./
SELECT DATE_TRUNC('month', creation_date)::date AS mnth,
       SUM(views_count) 
FROM stackoverflow.posts
GROUP BY DATE_TRUNC('month', creation_date)
ORDER BY SUM(views_count) DESC

/2.
Выведите имена самых активных пользователей, которые в первый месяц после регистрации (включая день регистрации) в сумме по имени дали более 100 ответов. 
Вопросы, которые задавали пользователи, не учитывайте. 
Для каждого имени пользователя выведите количество уникальных значений user_id, соответствующих этому имени. 
Отсортируйте результат по полю с именами в лексикографическом порядке./
select u.display_name,
    count(distinct p.user_id)
From stackoverflow.posts AS p
Join stackoverflow.users as u on u.id = p.user_id

WHERE p.post_type_id = 2
and p.creation_date::date between u.creation_date::date and (u.creation_date::date + interval '1 month')
group by u.display_name
having count(distinct p.id) >100
order by u.display_name

/3.
Выведите количество постов за 2008 год по месяцам. 
Отберите посты от пользователей, которые зарегистрировались в сентябре 2008 года и сделали хотя бы один пост в декабре того же года. 
Отсортируйте таблицу по значению месяца по убыванию./
SELECT 
   DATE_TRUNC('month', p.creation_date)::date AS month_pst,
    COUNT(DISTINCT p.id) AS post_count
FROM stackoverflow.posts AS p
JOIN stackoverflow.users AS u 
    ON u.id = p.user_id
WHERE DATE_TRUNC('month', u.creation_date) = '2008-09-01'
and p.user_id in (
    SELECT user_id
    FROM stackoverflow.posts
    WHERE DATE_TRUNC('month', creation_date)::date = '2008-12-01'
)
GROUP BY DATE_TRUNC('month', p.creation_date)
ORDER BY month_pst DESC

/4.
Используя данные о постах, выведите несколько полей:
идентификатор пользователя, который написал пост;
дата создания поста;
количество просмотров у текущего поста;
сумма просмотров постов автора с накоплением.
Данные в таблице должны быть отсортированы по возрастанию идентификаторов пользователей, а данные об одном и том же пользователе — по возрастанию даты создания поста./
select 
    user_id,
    creation_date,
    views_count,
    sum(views_count) over(partition by user_id order by creation_date) as cum_views
from stackoverflow.posts 
order by user_id asc

/5.
Сколько в среднем дней в период с 1 по 7 декабря 2008 года включительно пользователи взаимодействовали с платформой? 
Для каждого пользователя отберите дни, в которые он или она опубликовали хотя бы один пост. 
Нужно получить одно целое число — не забудьте округлить результат./
with q as(
 select 
    user_id
    ,count(distinct(creation_date::date)) as days
 from stackoverflow.posts
 where creation_date::date between '2008-12-01' and '2008-12-07'
 group by user_id
    )
    
SELECT 
    ROUND(AVG(days)) AS avg_post_count
FROM q;

/6.
На сколько процентов менялось количество постов ежемесячно с 1 сентября по 31 декабря 2008 года? Отобразите таблицу со следующими полями:
- Номер месяца.
- Количество постов за месяц.
- Процент, который показывает, насколько изменилось количество постов в текущем месяце по сравнению с предыдущим.
Если постов стало меньше, значение процента должно быть отрицательным, если больше — положительным. 
Округлите значение процента до двух знаков после запятой./
with aq as(
select 
    extract(month from creation_date::date) as post_month
    ,count(distinct(id)) as post_cnt
from stackoverflow.posts
where extract(month from creation_date::date) between 9 and 12
group by extract(month from creation_date::date)

)

select
    post_month
    ,post_cnt
    
    ,round (((post_cnt::numeric / lag(post_cnt) over (order by post_month)::numeric-1)* 100),2)  as change
from aq

/7.
Найдите пользователя, который опубликовал больше всего постов за всё время с момента регистрации. Выведите данные его активности за октябрь 2008 года в таком виде:
номер недели;
дата и время последнего поста, опубликованного на этой неделе./
with q as(
    SELECT user_id,
                   COUNT(DISTINCT id) AS cnt
                   FROM stackoverflow.posts
                   GROUP BY user_id
                   ORDER BY cnt DESC
                   LIMIT 1
 )
  ,w as (select 
     extract(week from creation_date) as week 
     ,max(creation_date) over (partition by extract(week from creation_date))::timestamp as last_post
from stackoverflow.posts as p
join q 
on q.user_id = p.user_id
where date_trunc('month' ,creation_date)::date = '2008-10-01'
)

Select week
    , max(last_post)
From w
group by week
