ЧАСТЬ 1

Задача 1

SELECT COUNT(id)
FROM stackoverflow.posts AS p 
WHERE  post_type_id =1  AND (score>300 OR favorites_count>=100); 

Задача 2

WITH tab AS
     (SELECT CAST(DATE_TRUNC('day', p.creation_date) AS DATE) AS day_date,       
             COUNT(p.id) AS question_cnt
     FROM stackoverflow.posts AS p
     WHERE post_type_id=1 
     GROUP BY CAST(DATE_TRUNC('day', p.creation_date) AS DATE)
     HAVING CAST(DATE_TRUNC('day', p.creation_date) AS DATE) BETWEEN '2008-11-01' AND '2008-11-18')
SELECT ROUND(AVG(question_cnt))
FROM tab;

Задача 3

SELECT 
      COUNT(DISTINCT(u.id)) AS users_cnt
FROM stackoverflow.users AS u
JOIN stackoverflow.badges AS b ON b.user_id=u.id
WHERE DATE_TRUNC('day', u.creation_date :: DATE) = DATE_TRUNC('day', b.creation_date :: DATE);

Задача 4

SELECT COUNT(DISTINCT(p.id))
FROM stackoverflow.posts p
JOIN stackoverflow.users u ON u.id=p.user_id
JOIN stackoverflow.votes v ON v.post_id=p.id
WHERE u.display_name LIKE 'Joel Coehoorn'; 

Задача 5

SELECT *,
     RANK() OVER (ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id;

Задача 6

SELECT u.id,
     COUNT(vt.name) votes_cnt
FROM stackoverflow.users u
JOIN stackoverflow.votes v ON u.id=v.user_id
JOIN stackoverflow.vote_types vt ON v.vote_type_id=vt.id
WHERE vt.name= 'Close'
GROUP BY u.id
ORDER BY votes_cnt DESC, id DESC
LIMIT 10;

Задача 7

SELECT user_id,
       COUNT(id) AS badges_cnt,
       DENSE_RANK() OVER( ORDER BY COUNT(id) DESC)
FROM stackoverflow.badges
WHERE CAST(creation_date AS DATE) BETWEEN '2008-11-15' AND '2008-12-15'
GROUP BY user_id
ORDER BY badges_cnt DESC, user_id 
LIMIT 10;

Задача 8

SELECT title,
       user_id,
       score,
       ROUND(AVG(score) OVER(PARTITION BY user_id)) AS avg_score
FROM stackoverflow.posts p
WHERE title IS NOT NULL AND score!=0
GROUP BY title, user_id, score;

Задача 9

SELECT p.title
FROM stackoverflow.posts p
JOIN stackoverflow.users u ON p.user_id=u.id
JOIN stackoverflow.badges b ON b.user_id=u.id
WHERE p.title IS NOT NULL 
GROUP BY p.title
HAVING COUNT(b.id)>1000;

Задача 10

SELECT id,
      views,
      CASE
         WHEN views <100  THEN 3 
         WHEN views <350  THEN 2        
         WHEN views >=350 THEN 1
      END AS category
FROM stackoverflow.users
WHERE location LIKE '%Canada%' AND views!=0;

Задача 11

WITH
tab1 AS
   (SELECT id,
           views,
           CASE 
              WHEN views <100  THEN 3 
              WHEN views <350  THEN 2        
              WHEN views >=350 THEN 1
              END AS category       
    FROM stackoverflow.users u
    WHERE location LIKE '%Canada%' AND views!=0),
tab2 AS
    (SELECT id,
            views,
            category,
            MAX(views) OVER (PARTITION BY category) AS max_views
    FROM tab1)
SELECT id,
       category,
       views
FROM tab2
WHERE views = max_views
ORDER BY views DESC, id;
  
Задача 12

WITH
tab AS
     (SELECT
           CAST(DATE_TRUNC('day', creation_date) AS DATE)  AS day_date,
           COUNT(id) AS cnt_id
           FROM stackoverflow.users  
           GROUP BY day_date
           ORDER BY day_date)
SELECT RANK() OVER(ORDER BY day_date),
       cnt_id,
       SUM(cnt_id) OVER(ORDER BY day_date) AS sum_cnt_id
FROM tab
WHERE CAST(DATE_TRUNC('day', day_date) AS date) BETWEEN '2008-11-01' AND '2008-11-30';

Задача 13

WITH tab AS
      (SELECT user_id,
              creation_date,
              RANK() OVER (PARTITION BY user_id ORDER BY creation_date)  AS first_post 
      FROM stackoverflow.posts 
      ORDER BY user_id)
SELECT user_id, 
       tab.creation_date - u.creation_date
FROM tab
JOIN stackoverflow.users u ON tab.user_id = u.id
WHERE first_post =1;


