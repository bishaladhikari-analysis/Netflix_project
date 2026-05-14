-- Netflix Project
Drop Table if exists Netflix;
create Table Netflix(

show_id varchar(10) primary key,
type varchar(10),	
title varchar(150),
director varchar(215),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(10),
listed_in varchar(100),
description varchar(300)
)

select * from Netflix;

-- count all data 
select 
count(*) as total_content
from Netflix;

--how any different types of unique  show/contain we have?
select Distinct type from Netflix;


-- 15 business problems 
--1) count the number of Movies and TV shows
select 
Distinct type,
count(*) as total_number 
from Netflix
group by type

--2)find the most common rating for movies and TV shows
SELECT 
    type,
    rating,
    COUNT(*) AS total_count
FROM Netflix
GROUP BY type, rating
ORDER BY type, total_count DESC;
-- alternative 
select 
type,
rating,
count(*)
from Netflix
Group by 1,2
order by 1,3 desc

--alternative 
select 
type,
rating,
count(*),
rank() over(partition by type order by count(*) desc) as ranking
from Netflix
Group by 1,2

--3)list all movies released in a specific year (e.g.2020)
select *
from Netflix
where 
type = 'Movie'
and 
release_year ='2020';

--4)find the top 7 countries with the most content on Netflix
--first one is more accurate 
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
    COUNT(*) AS total_content
FROM Netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 7;
-- alternative 
select
unnest(string_to_array(country, ',')) as new_country,
count(show_id) as total_content
from Netflix
group by 1 
order by 2 desc
limit 7

--5)find the longest Movie?
select * from Netflix
where 
type = 'Movie'
and 
duration = (select max(duration) from Netflix)

--6) find the content added in the last 5 years
select *
from Netflix
where 
to_date(date_added, 'Month dd, yyyy') >= current_date - interval '5 years'

--7)find all the movies/TV shows by director  'Rajiv chilaka'
select *
from Netflix
where
director like '%Rajiv Chilaka%'

--8)list all tv shows with more than 5 seasons
SELECT *
FROM Netflix
WHERE type = 'TV Show'
AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;
--alternative
SELECT *
FROM Netflix
WHERE type = 'TV Show'
AND duration ILIKE '%season%'
AND CAST(TRIM(SPLIT_PART(duration, ' ', 1)) AS INT) > 5;
--alternative 
SELECT *
FROM Netflix
WHERE type = 'TV Show'
and
SPLIT_PART(duration, ' ', 1)::numeric > 5;

--9) count the number of content items in each genre
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(*) AS total_content
FROM Netflix
GROUP BY 1
ORDER BY 2 DESC;
--alternative 
select 
unnest(string_to_array(listed_in, ',')) as genre,
count(show_id) as total_content
from Netflix
group by 1

--10)find each years and the average number of content release by india on netflix. return top 5 year with highest avg content release!
--(“Find top 5 years with highest Indian content release”)
SELECT
    release_year,
    COUNT(*) AS total_content
FROM Netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
--alternative 
--(“Find yearly average/percentage contribution”)
select 
extract(year from to_date(date_added, 'Month dd, yyyy')) as year, 
count(*) as yearly_content,
round (
count(*):: numeric/(select count(*) from Netflix 
where
country ='India'
):: numeric * 100, 2) as avg_content_per_year
from Netflix
where 
country = 'India'
group by 1

--11)list all the movies that are documentaries
select * from Netflix
where 
listed_in like  '%Documentaries%'

--12) find all content without a director 
select * from Netflix 
where 
director is Null

-- 13)find how many movies actor 'Salman Khan' appered in last 10 years
select * from Netflix
where 
casts Ilike '%Salman Khan%'
and 
release_year > extract(year from current_date ) - 10

--14)find the top 10 actors who have appered in the highest number of movies produced in india.
select
unnest (string_to_array(casts, ',')) as actors,
count(*) as total_content 
from Netflix
where  
country Like '%India%'
--alternative 
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
    COUNT(*) AS total_movies
FROM Netflix
WHERE country ILIKE '%India%'
    AND type = 'Movie'
    AND casts IS NOT NULL
GROUP BY actor
ORDER BY total_movies DESC
LIMIT 10;
group by 1
order by 2 desc
limit 10

--15)categories the content based on the presence of the keywords 'kill' and  'violence' in the description field. label content containing these keywords as 'bad' and all other content as 'Good'.count how many items fall into each category.

SELECT 
    CASE
        WHEN description ILIKE '%kill%' 
          OR description ILIKE '%violence%'
        THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    
    COUNT(*) AS total_content

FROM Netflix

GROUP BY content_category;
--alternative
SELECT 
    CASE 
        WHEN description ILIKE ANY (ARRAY['%kill%', '%violence%'])
        THEN 'Bad'
        ELSE 'Good'
    END AS category,
    
    COUNT(*) AS total

FROM Netflix

GROUP BY category;