--Find all movies released in 2019
SELECT * FROM  movies
WHERE release_date 
BETWEEN '2019-01-01'
AND '2019-12-31';

--Find all actors from British nationality
SELECT * FROM actors
WHERE LOWER(nationality) = 'british';

--Find all movies with PG 13 rating
SELECT * FROM  movies
WHERE rating = 'PG-13';

--Find all directors from American nationality
--only american
SELECT * FROM directors
WHERE LOWER(nationality) = 'american'; 

--american + other
SELECT * FROM directors
WHERE LOWER(nationality) LIKE '%american%';

--Find all movies with duration more than 150 minutes
SELECT * FROM  movies
WHERE duration_minutes > 150

--Find all actors with last name Pitt
SELECT * FROM actors
WHERE last_name = 'Pitt';

SELECT * FROM actors
WHERE last_name LIKE '%Pitt%';

--Find all movies with budget greater than 100 million
SELECT * FROM  movies
WHERE budget > 100000000;

--Find all reviews with rating 5
SELECT * FROM  reviews
WHERE rating = 5;

--Find all movies in English language
SELECT * FROM  movies
WHERE LOWER(language) = 'english';

--Find all production companies from 'California'
SELECT * FROM  production_companies
WHERE LOWER(headquarters) LIKE '%california%';