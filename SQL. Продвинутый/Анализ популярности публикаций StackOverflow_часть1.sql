/1.
Найдите количество вопросов, которые набрали больше 300 очков или как минимум 100 раз были добавлены в «Закладки»./
SELECT count(1)
FROM stackoverflow.posts 
where post_type_id = 1
  and score > 300
   or favorites_count > 100

/2.
Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно? Результат округлите до целого числа./
Select 
    round(avg(count)) 
From (
    select 
         date_trunc('day', creation_date)::date  as post_day
         ,count(distinct(id))
    from stackoverflow.posts 
    where post_type_id=1
    and date_trunc('day', creation_date)::date between '2008-11-01' and '2008-11-18'
    group by date_trunc('day', creation_date)::date
    )as q

/3.
Сколько пользователей получили значки сразу в день регистрации? Выведите количество уникальных пользователей./
Select count(distinct(user_id))
from(
    Select 
        b.user_id
        ,date_trunc('day', u.creation_date)::date as account_date
        ,date_trunc('day', u.creation_date)::date as badges_date
    From stackoverflow.users as u 
    join stackoverflow.badges as b
    on u.id=b.user_id
    ) as q
where  account_date=badges_date

/4.
Сколько уникальных постов пользователя с именем Joel Coehoorn получили хотя бы один голос?/
select count(distinct(p.id))
from stackoverflow.posts as p
left join stackoverflow.users as u on p.user_id = u.id
left join stackoverflow.votes as v on p.id = v.post_id
where u.display_name = 'Joel Coehoorn'
  and v.post_id is not NULL

/5.
Выгрузите все поля таблицы vote_types. Добавьте к таблице поле rank, в которое войдут номера записей в обратном порядке. Таблица должна быть отсортирована по полю id./
select *
       ,row_number() over(order by id desc) as rank
from stackoverflow.vote_types
order by id

/6.
Отберите 10 пользователей, которые поставили больше всего голосов типа Close. 
Отобразите таблицу из двух полей: идентификатором пользователя и количеством голосов. 
Отсортируйте данные сначала по убыванию количества голосов, потом по убыванию значения идентификатора пользователя./
select v.user_id, count(v.vote_type_id) as cnt
from stackoverflow.votes as v
left join stackoverflow.vote_types as vt on v.vote_type_id = vt.id
where vt.name = 'Close' 
group by v.user_id
order by cnt desc
limit 10

/7.
Отберите 10 пользователей по количеству значков, полученных в период с 15 ноября по 15 декабря 2008 года включительно.
Отобразите несколько полей:
идентификатор пользователя;
число значков;
место в рейтинге — чем больше значков, тем выше рейтинг.
Пользователям, которые набрали одинаковое количество значков, присвойте одно и то же место в рейтинге.
Отсортируйте записи по количеству значков по убыванию, а затем по возрастанию значения идентификатора пользователя./
select user_id
       ,count(1) as cnt
       ,dense_rank() over(order by count(1) desc) as rank
from stackoverflow.badges 
where creation_date::date between '2008-11-15' and '2008-12-15'
group by user_id
order by cnt desc, user_id asc
limit 10

/8.
Сколько в среднем очков получает пост каждого пользователя?
Сформируйте таблицу из следующих полей:
заголовок поста;
идентификатор пользователя;
число очков поста;
среднее число очков пользователя за пост, округлённое до целого числа.
Не учитывайте посты без заголовка, а также те, что набрали ноль очков./
select title
       ,user_id
       ,score
       ,(avg(score) over(partition by user_id))::int 
from stackoverflow.posts
where title is not null
  and score != 0

/9.
Отобразите заголовки постов, которые были написаны пользователями, получившими более 1000 значков. Посты без заголовков не должны попасть в список./
with scored_users as (
    select user_id
    from stackoverflow.badges 
    group by user_id
    having count(1) > 1000
    )
select title
from stackoverflow.posts
where user_id in (select user_id from scored_users)
  and title is not null

/10.
Напишите запрос, который выгрузит данные о пользователях из Канады (англ. Canada). Разделите пользователей на три группы в зависимости от количества просмотров их профилей:
пользователям с числом просмотров больше либо равным 350 присвойте группу 1;
пользователям с числом просмотров меньше 350, но больше либо равно 100 — группу 2;
пользователям с числом просмотров меньше 100 — группу 3.
Отобразите в итоговой таблице идентификатор пользователя, количество просмотров профиля и группу. Пользователи с количеством просмотров меньше либо равным нулю не должны войти в итоговую таблицу./
select id
       ,views
       ,case
           when views >= 350 then 1
           when (views >= 100) and (views < 350) then 2
           else 3
        end
from stackoverflow.users
where location like '%Canada%'
  and views >0

/11.
Дополните предыдущий запрос. Отобразите лидеров каждой группы — пользователей, которые набрали максимальное число просмотров в своей группе. 
Выведите поля с идентификатором пользователя, группой и количеством просмотров. 
Отсортируйте таблицу по убыванию просмотров, а затем по возрастанию значения идентификатора./
select id
       ,gr
       ,views 
from (
select id
       ,gr
       ,views 
       ,max(views) over(partition by gr) as max_views
from ( 
select id
       ,views
       ,case
           when views >= 350 then 1
           when (views >= 100) and (views < 350) then 2
           else 3
        end as gr
from stackoverflow.users
where location like '%Canada%'
  and views >0
    ) t1
    )t2
where views = max_views
order by views desc, id asc

/12.
Посчитайте ежедневный прирост новых пользователей в ноябре 2008 года. Сформируйте таблицу с полями:
номер дня;
число пользователей, зарегистрированных в этот день;
сумму пользователей с накоплением./
select *
       ,sum(users) over(order by day asc)
from (
select extract('day' from creation_date::date) as day
       ,count(distinct(id)) as users
from stackoverflow.users
where date_trunc('month', creation_date::date) = '2008-11-01'
group by day
    ) t1

/13.
Для каждого пользователя, который написал хотя бы один пост, найдите интервал между регистрацией и временем создания первого поста. Отобразите:
идентификатор пользователя;
разницу во времени между регистрацией и первым постом./
select user_id
    --,max(account_create)
    ,max(first_post)
from(
    select  
       p.user_id
       ,u.creation_date as account_create 
       ,(min(p.creation_date) over (partition by p.user_id order by p.creation_date asc)- u.creation_date ) as first_post   
    from  stackoverflow.posts as p left join stackoverflow.users as u on p.user_id=u.id
        ) as  q
group by user_id

