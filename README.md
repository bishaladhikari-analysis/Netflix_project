# Netflix_project
Analyzed Netflix movies and TV shows data using SQL to discover content trends, top actors, genre distribution, ratings, and country-wise streaming insights.
# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/bishaladhikari-analysis/Netflix_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;

--unique results:-

select 
Distinct type,
count(*) as total_number 
from Netflix
group by type
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```
```sql
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

```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select *
from Netflix
where 
type = 'Movie'
and 
release_year ='2020';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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

```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

--alternative

select * from Netflix
where 
type = 'Movie'
and 
duration = (select max(duration) from Netflix)
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

--alternative:

select *
from Netflix
where
director like '%Rajiv Chilaka%'
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
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

```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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

```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

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

```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

-- alternative:

select
unnest (string_to_array(casts, ',')) as actors,
count(*) as total_content 
from Netflix
where  
country Like '%India%'
group by 1
order by 2 desc
limit 10

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

```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;

--alternative:

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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Zero Analyst

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media and join our community:

- **Instagram**: [Follow me for daily tips and updates](https://www.instagram.com/bishaladhikari859/)
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/bishal-adhikari-3b3579398/)

