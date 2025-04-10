-- Homework requirements 1/2
-- Find all genres that have more than 3 movies with a rating of 'R'
SELECT g.name AS genre_name, COUNT(*) as movie_count
FROM genres g
JOIN movie_genres mg ON g.genre_id = mg.genre_id
JOIN movies m ON mg.movie_id = m.movie_id
WHERE m.rating = 'R'
GROUP BY g.name
HAVING COUNT(m.movie_id) > 3;

-- Find directors who have made movies with total revenue over 500 million and have directed at least 2 movies
SELECT d.first_name, d.last_name, 
       --SUM(mr.domestic_revenue) AS total_domestic_revenue, 
       --SUM(mr.international_revenue) AS total_international_revenue, 
       SUM(mr.domestic_revenue + mr.international_revenue) AS total_revenue
FROM directors d
JOIN movies m ON d.director_id = m.director_id
JOIN movie_revenues mr ON m.movie_id = mr.movie_id
GROUP BY d.first_name, d.last_name
HAVING SUM(mr.domestic_revenue + mr.international_revenue) > 500000000 
       AND COUNT(m.movie_id) >= 2;

-- Find actors who have appeared in more than 2 different genres and have won at least 1 award
SELECT a.first_name, a.last_name
FROM actors a
JOIN cast_members cm ON a.actor_id = cm.actor_id
JOIN movies m ON cm.movie_id = m.movie_id
JOIN movie_genres mg ON m.movie_id = mg.movie_id
JOIN actor_awards aw ON a.actor_id = aw.actor_id  -- Assuming actor_awards links actors to awards
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(DISTINCT mg.genre_id) > 2 AND COUNT(DISTINCT aw.award_id) >= 1;


-- Find movies that have received more than 3 reviews with an average rating above 7
SELECT m.title, AVG(r.rating) AS average_rating, COUNT(r.review_id) AS review_count
FROM movies m
JOIN reviews r ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title
HAVING COUNT(r.review_id) > 3 AND AVG(r.rating) > 7;

-- Find production companies that have invested more than 100 million in movies released after 2015
SELECT pc.name AS production_company_name, SUM(mpc.investment_amount) AS total_investment
FROM production_companies pc
JOIN movie_production_companies mpc ON pc.company_id = mpc.company_id
JOIN movies m ON mpc.movie_id = m.movie_id
WHERE EXTRACT(YEAR FROM m.release_date) > 2015
GROUP BY pc.company_id, pc.name
HAVING SUM(mpc.investment_amount) > 100000000;

-- Find countries where more than 2 movies were filmed with a total budget exceeding 150 million
SELECT ml.country AS country_name, COUNT(m.movie_id) AS movie_count, SUM(m.budget) AS total_budget
FROM movie_locations ml
JOIN movies m ON ml.movie_id = m.movie_id
GROUP BY ml.country
HAVING COUNT(m.movie_id) > 2 AND SUM(m.budget) > 150000000;


-- Find genres where the average movie duration is over 120 minutes and at least one movie has won an Oscar
SELECT g.name AS genre_name, ROUND(AVG(m.duration_minutes), 1) AS average_duration
FROM genres g
JOIN movie_genres mg ON g.genre_id = mg.genre_id
JOIN movies m ON mg.movie_id = m.movie_id
JOIN movie_awards ma ON m.movie_id = ma.movie_id
JOIN awards a ON ma.award_id = a.award_id  
WHERE a.award_type = 'Oscar'  
GROUP BY g.genre_id, g.name
HAVING AVG(m.duration_minutes) > 120 AND COUNT(DISTINCT a.award_id) > 0;


-- another solution:
-- SELECT
--     g.name AS genre_name,
--     ROUND(AVG(m.duration_minutes), 1) AS average_duration
-- FROM genres g
-- JOIN movie_genres mg ON g.genre_id = mg.genre_id
-- JOIN movies m ON mg.movie_id = m.movie_id
-- WHERE EXISTS (
--     SELECT 1
--     FROM movie_awards ma
--     JOIN awards a ON ma.award_id = a.award_id
--     WHERE ma.movie_id = m.movie_id
--       AND a.award_type = 'Oscar'
-- )
-- GROUP BY g.genre_id, g.name
-- HAVING AVG(m.duration_minutes) > 120;

-- Find years where more than 3 movies were released with an average budget over 50 million
SELECT release_date, COUNT(movie_id) AS movie_count, AVG(budget) AS average_budget
FROM movies
GROUP BY release_date
HAVING COUNT(movie_id) > 3 AND AVG(budget) > 50000000;

--solution 2:
-- SELECT
--     EXTRACT(YEAR FROM release_date) AS release_year,
--     COUNT(*) AS movie_count,
--     ROUND(AVG(budget) / 1e6, 2) AS average_budget_millions
-- FROM movies
-- GROUP BY EXTRACT(YEAR FROM release_date)
-- HAVING 
--     COUNT(*) > 3 
--     AND AVG(budget) > 50000000  -- 50 million dollars
-- ORDER BY release_year DESC;


-- Find actors who have played lead roles in more than 2 movies with a total revenue exceeding 200 million
SELECT a.first_name, a.last_name, 
       COUNT(m.movie_id) AS movie_count, 
       SUM(mr.domestic_revenue + mr.international_revenue) AS total_revenue
FROM actors a
JOIN cast_members cm ON a.actor_id = cm.actor_id
JOIN movies m ON cm.movie_id = m.movie_id
JOIN movie_revenues mr ON mr.movie_id = m.movie_id
WHERE cm.is_lead_role = true  
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(m.movie_id) > 2 
   AND SUM(mr.domestic_revenue + mr.international_revenue) > 200000000;

--solution + :
/*
SELECT
    a.first_name,
    a.last_name,
    COUNT(DISTINCT m.movie_id) AS movie_count,
    ROUND(SUM(mr.domestic_revenue + mr.international_revenue) / 1e6, 2) AS total_revenue_millions
FROM actors a
JOIN cast_members cm ON a.actor_id = cm.actor_id
JOIN movies m ON cm.movie_id = m.movie_id
JOIN movie_revenues mr ON mr.movie_id = m.movie_id
WHERE cm.is_lead_role = TRUE
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING 
    COUNT(DISTINCT m.movie_id) > 2 
    AND SUM(mr.domestic_revenue + mr.international_revenue) > 200000000  -- 200 million dollars
ORDER BY total_revenue_millions DESC;

*/

-- Homework requirements 2/2
-- Create a view that shows top-rated movies. Include: movie title, average rating, review count, director name
CREATE VIEW top_rated_movies AS
SELECT
    m.title AS movie_title,
    ROUND(AVG(r.rating), 1) AS average_rating,
    COUNT(r.rating) AS review_count,
    CONCAT(d.first_name, ' ', d.last_name) AS director_full_name
FROM
    movies m
JOIN
    reviews r ON m.movie_id = r.movie_id
JOIN
    directors d ON m.director_id = d.director_id
GROUP BY
    m.movie_id, m.title, d.first_name, d.last_name
ORDER BY
    average_rating DESC;

SELECT * FROM top_rated_movies

-- Create a view for movie financial performance. Include: movie title, budget, total revenue, profit, ROI
CREATE VIEW movie_financial_performance AS
SELECT
    m.title AS movie_title,
    m.budget AS budget,
    SUM(mr.domestic_revenue + mr.international_revenue) AS total_revenue,
    SUM(mr.domestic_revenue + mr.international_revenue) - m.budget AS profit,
    ROUND(
        (SUM(mr.domestic_revenue + mr.international_revenue) - m.budget) / m.budget * 100,
        2
    ) AS roi_percentage
FROM
    movies m
JOIN
    movie_revenues mr ON m.movie_id = mr.movie_id
GROUP BY
    m.movie_id, m.title, m.budget
ORDER BY
    roi_percentage DESC;

SELECT * FROM movie_financial_performance
	

-- Create a view for actor filmography. Include: actor name, movie count, genre list, total revenue
CREATE VIEW actor_filmography AS
SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    COUNT(DISTINCT m.movie_id) AS movie_count,
    STRING_AGG(DISTINCT g.name, ', ' ORDER BY g.name) AS genre_list,
    SUM(mr.domestic_revenue + mr.international_revenue) AS total_revenue
FROM
    actors a
JOIN
    cast_members cm ON a.actor_id = cm.actor_id
JOIN
    movies m ON cm.movie_id = m.movie_id
JOIN
    movie_genres mg ON m.movie_id = mg.movie_id
JOIN
    genres g ON mg.genre_id = g.genre_id
JOIN
    movie_revenues mr ON m.movie_id = mr.movie_id
GROUP BY
    a.actor_id, a.first_name, a.last_name
ORDER BY
    total_revenue DESC;

SELECT * FROM actor_filmography
	

-- Create a view for genre statistics. Include: genre name, movie count, average rating, total revenue
CREATE VIEW genre_statistics AS
SELECT
    g.name AS genre_name,
    COUNT(DISTINCT m.movie_id) AS movie_count,
    ROUND(AVG(r.rating), 2) AS average_rating,
    SUM(mr.domestic_revenue + mr.international_revenue) AS total_revenue
FROM
    genres g
JOIN
    movie_genres mg ON g.genre_id = mg.genre_id
JOIN
    movies m ON mg.movie_id = m.movie_id
LEFT JOIN
    reviews r ON m.movie_id = r.movie_id
LEFT JOIN
    movie_revenues mr ON m.movie_id = mr.movie_id
GROUP BY
    g.genre_id, g.name
ORDER BY
    total_revenue DESC;

SELECT * FROM genre_statistics 

-- Create a view for production company performance. Include: company name, movie count, total investment, total revenue
CREATE VIEW production_company_performance AS
SELECT
    pc.name AS company_name,
    COUNT(DISTINCT m.movie_id) AS movie_count,
    SUM(m.budget) AS total_investment,
    COALESCE(SUM(mr.domestic_revenue + mr.international_revenue), 0) AS total_revenue
FROM
    movies m
JOIN
    movie_production_companies mpc ON mpc.movie_id = m.movie_id
JOIN
    production_companies pc ON pc.company_id = mpc.company_id
LEFT JOIN
    movie_revenues mr ON m.movie_id = mr.movie_id
GROUP BY
    pc.company_id, pc.name
ORDER BY
    total_revenue DESC;

SELECT * FROM production_company_performance

