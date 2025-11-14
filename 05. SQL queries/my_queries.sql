SELECT COUNT(*)
FROM stackoverflow.posts as p
LEFT JOIN stackoverflow.post_types as pt ON pt.id=p.post_type_id
WHERE (p.score>300 OR p.favorites_count>=100)
AND pt.type = 'Question'

-- 2. Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно? Результат округлите до целого числа.
SELECT ROUND(AVG(count_posts),0) AS avg_posts
FROM (SELECT creation_date::date AS dt,
       COUNT(p.id) AS count_posts
FROM stackoverflow.posts as p
LEFT JOIN stackoverflow.post_types as pt ON pt.id=p.post_type_id
WHERE pt.type = 'Question' AND creation_date::date BETWEEN '2008-11-01' AND '2008-11-18'
GROUP BY creation_date::date) AS pp

-- Сколько пользователей получили значки сразу в день регистрации? Выведите количество уникальных пользователей.
SELECT COUNT(DISTINCT u.id)
FROM stackoverflow.badges AS b
LEFT JOIN stackoverflow.users AS u ON u.id=b.user_id
WHERE DATE_TRUNC('day', b.creation_date)=DATE_TRUNC('day', u.creation_date)

-- 4. Сколько уникальных постов пользователя с именем Joel Coehoorn получили хотя бы один голос?
SELECT COUNT (DISTINCT p.id)
FROM stackoverflow.users AS u
LEFT JOIN stackoverflow.posts AS p ON p.user_id=u.id
LEFT JOIN stackoverflow.votes AS v ON p.id=v.post_id
WHERE display_name like ('Joel Coehoorn') AND v.id>=1

-- 5. Выгрузите все поля таблицы vote_types. Добавьте к таблице поле rank, в которое войдут номера записей в обратном порядке. Таблица должна быть отсортирована по полю id.
SELECT *,
       rank() OVER(ORDER BY vt.id DESC) 
FROM stackoverflow.vote_types AS vt
ORDER BY vt.id

--6. Отберите 10 пользователей, которые поставили больше всего голосов типа Close. Отобразите таблицу из двух полей: идентификатором пользователя и количеством голосов. Отсортируйте данные сначала по убыванию количества голосов, потом по убыванию значения идентификатора пользователя.
SELECT *
FROM (SELECT u.id AS user_id,
       count(post_id) as count_post
FROM stackoverflow.users AS u
LEFT JOIN stackoverflow.votes AS v ON u.id=v.user_id
LEFT JOIN stackoverflow.vote_types AS vt ON vt.id=v.vote_type_id
WHERE vt.name = 'Close'
GROUP BY u.id
ORDER BY count_post DESC
LIMIT 10) as max_post
ORDER BY count_post DESC, user_id DESC

--7. Отберите 10 пользователей по количеству значков, полученных в период с 15 ноября по 15 декабря 2008 года включительно.
SELECT *,
        DENSE_RANK() OVER (ORDER BY count_badges DESC)
FROM (SELECt u.id AS user_id,
       COUNT(b.id) as count_badges
FROM stackoverflow.users AS u
LEFT JOIN stackoverflow.badges AS b On u.id=b.user_id
WHERE DATE_TRUNC('day',b.creation_date) BETWEEN '2008-11-15' AND '2008-12-15'
GROUP BY u.id
ORDER BY count_badges DESC, user_id
LIMIT 10) as bb

--8. Сколько в среднем очков получает пост каждого пользователя?
SELECT ps.title,
       user_id,
       score,
       ROUND(AVG(score) OVER (PARTITION BY user_id),0) AS avg_score
FROM stackoverflow.posts as ps
WHERE ps.title is not null AND ps.score != 0

--9. Отобразите заголовки постов, которые были написаны пользователями, получившими более 1000 значков. Посты без заголовков не должны попасть в список.
SELECT title
FROM stackoverflow.posts AS pp
WHERE pp.user_id IN (SELECT b.user_id
        FROM stackoverflow.badges AS b
        GROUP BY b.user_id
        HAVING COUNT(b.id) > 1000) AND title IS NOT NULL

--10. Напишите запрос, который выгрузит данные о пользователях из Канады (англ. Canada). Разделите пользователей на три группы в зависимости от количества просмотров их профилей:
SELECt us.id,
       us.views,
       CASE
           WHEN us.views < 100 THEN 3
           WHEN us.views >= 100 AND us.views < 350 THEN 2
           WHEN us.views >= 350 THEN 1
       END
FROM stackoverflow.users AS us
WHERE us.location LIKE '%Canada' AND us.views > 0
