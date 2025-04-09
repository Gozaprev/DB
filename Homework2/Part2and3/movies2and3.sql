-- Homework requirement 2/3
-- Show movies and their directors
SELECT * FROM movies
SELECT * FROM directors

SELECT movies.title, directors.first_name, directors.last_name FROM movies
INNER JOIN directors
ON movies.director_id = directors.director_id;


-- Show actors and their movies
SELECT m.title AS "movieTitle", a.first_name, a.last_name
FROM movies m
INNER JOIN cast_members cm ON cm.movie_id = m.movie_id
INNER JOIN actors a ON a.actor_id = cm.actor_id;


-- Show movies and their genres
SELECT movies.title, genres.name FROM movies
INNER JOIN movie_genres ON movie_genres.movie_id = movies.movie_id
INNER JOIN genres ON movie_genres.genre_id = genres.genre_id;

-- Show users and their reviews
SELECT username, review_text FROM users u
INNER JOIN reviews r
ON r.user_id = u.user_id;


-- Show movies and their locations
SELECT m.title, ml.city
FROM movies m
INNER JOIN movie_locations ml ON ml.movie_id = m.movie_id;

-- Show movies and their production companies
SELECT m.title, pc.name
FROM movies m 
INNER JOIN movie_production_companies mpc ON mpc.movie_id = m.movie_id
INNER JOIN production_companies pc ON pc.company_id = mpc.company_id;


-- Show actors and their awards
SELECT ac.first_name, ac.last_name, a.name, a.award_type 
FROM actors ac
INNER JOIN actor_awards aw ON aw.actor_id = ac.actor_id
INNER JOIN awards a ON aw.award_id = a.award_id;

-- Show movies and their awards
SELECT m.title, a.name, a.award_type 
FROM movies m
INNER JOIN movie_awards mw ON mw.movie_id = m.movie_id
INNER JOIN awards a ON mw.award_id = a.award_id;

-- Show users and their watchlist movies
SELECT u.username, m.title AS "WatchList_movies"
FROM movies m
INNER JOIN user_watchlist uw ON uw.movie_id = m.movie_id
INNER JOIN users u ON uw.user_id = u.user_id;

-- Show movies and their revenues
SELECT m.title, mr.domestic_revenue, mr.international_revenue 
FROM movie_revenues mr
INNER JOIN movies m ON mr.movie_id = m.movie_id;

-- Homework requirement 3/3
-- Show all R-rated movies and their directors
SELECT m.title, m.rating, d.first_name, d.last_name
FROM movies m
INNER JOIN directors d ON m.director_id = d.director_id
WHERE m.rating = 'R'

-- Show all movies from 2019 and their genres
SELECT movies.title, genres.name, movies.release_date  FROM movies
INNER JOIN movie_genres ON movie_genres.movie_id = movies.movie_id
INNER JOIN genres ON movie_genres.genre_id = genres.genre_id
WHERE movies.release_date BETWEEN '2019-01-01' AND '2019-12-31';
--WHERE EXTRACT(YEAR FROM movies.release_date) = 2019; - this is also a solution

-- Show all American actors and their movies
SELECT a.first_name, a.last_name, a.nationality, m.title AS "movieTitle" 
FROM movies m
INNER JOIN cast_members cm ON cm.movie_id = m.movie_id
INNER JOIN actors a ON a.actor_id = cm.actor_id
WHERE LOWER(a.nationality) LIKE '%american%';


-- Show all movies with budget over 100M and their production companies
SELECT m.title, pc.name
FROM movies m 
INNER JOIN movie_production_companies mpc ON mpc.movie_id = m.movie_id
INNER JOIN production_companies pc ON pc.company_id = mpc.company_id
WHERE m.budget > 100000000;


-- Show all movies filmed in 'London' and their directors
SELECT movies.title, directors.first_name, directors.last_name, movie_locations.city, movie_locations.country FROM movies
INNER JOIN directors ON movies.director_id = directors.director_id
INNER JOIN movie_locations ON movie_locations.movie_id = movies.movie_id
WHERE LOWER(city) = 'London';


-- Show all horror movies and their actors
SELECT m.title, g.name, a.first_name, a.last_name
FROM movies m
INNER JOIN movie_genres mg ON mg.movie_id = m.movie_id
INNER JOIN genres g ON g.genre_id = mg.genre_id
INNER JOIN cast_members cm ON cm.movie_id = m.movie_id
INNER JOIN actors a ON a.actor_id = cm.actor_id
WHERE LOWER(g.name) = 'horror';

-- Show all movies with reviews rated 5 and their reviewers
SELECT m.title, u.username, r.rating
FROM movies m
INNER JOIN reviews r ON r.movie_id = m.movie_id
INNER JOIN users u ON r.user_id = u.user_id
WHERE r.rating = 5;


-- Show all British directors and their movies
SELECT m.title, d.first_name, d.last_name, d.nationality 
FROM movies m
INNER JOIN directors d ON m.director_id = d.director_id
WHERE LOWER(d.nationality) LIKE '%british%'

-- Show all movies longer than 180 minutes and their genres
SELECT m.title, g.name 
FROM movies m
INNER JOIN movie_genres mg ON mg.movie_id = m.movie_id
INNER JOIN genres g ON mg.genre_id = g.genre_id
WHERE m.duration_minutes > 180

-- Show all Oscar-winning movies and their directors
SELECT m.title, a.name, a.award_type, d.first_name, d.last_name
FROM movies m
INNER JOIN movie_awards mw ON mw.movie_id = m.movie_id
INNER JOIN awards a ON mw.award_id = a.award_id
INNER JOIN directors d ON m.director_id = d.director_id
WHERE LOWER(a.award_type::text) = 'oscar';

--since the award_type is user defined data type -> checked by:
/*
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'awards';
*/
