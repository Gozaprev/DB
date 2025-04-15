--Homework4

--1
-- User-defined functions
-- Get movies by rating (table-valued function)
-- -- Usage example:
-- SELECT * FROM get_movies_by_rating('PG-13');
SELECT * FROM movies
SELECT * FROM genres
SELECT * FROM movie_genres



--DROP FUNCTION get_movies_by_rating

CREATE OR REPLACE FUNCTION get_movies_by_rating(rating_param mpaa_rating)
RETURNS TABLE(
    movie_id INT,
    title VARCHAR(255),
    release_date INT,  -- Matches EXTRACT(YEAR) result
    genre VARCHAR(50),
    rating mpaa_rating
) AS $$
BEGIN 
    RETURN QUERY
    SELECT 
        m.movie_id, 
        m.title, 
        EXTRACT(YEAR FROM m.release_date)::INT,  -- Year extraction + cast
        g.name, 
        m.rating
    FROM movies m
    INNER JOIN movie_genres mg ON mg.movie_id = m.movie_id
    INNER JOIN genres g ON g.genre_id = mg.genre_id
    WHERE m.rating = rating_param;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_movies_by_rating('PG-13');


--2
-- Get director's filmography (table-valued function)
-- -- Usage example:
-- SELECT * FROM get_director_filmography(1);

CREATE OR REPLACE FUNCTION get_director_filmography(director_id_param INT)
RETURNS TABLE(
    movie_id INT,
    title VARCHAR,
    release_year INT,
    genres TEXT,
    director_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.movie_id,
        m.title,
        EXTRACT(YEAR FROM m.release_date)::INT AS release_year,
        STRING_AGG(g.name, ', ')::TEXT AS genres,  -- Aggregate genres
        d.first_name || ' ' || d.last_name AS director_name
    FROM movies m
    INNER JOIN directors d ON m.director_id = d.director_id
    LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id  -- LEFT JOIN to include movies without genres
    LEFT JOIN genres g ON mg.genre_id = g.genre_id
    WHERE d.director_id = director_id_param
    GROUP BY m.movie_id, d.director_id;  -- Group by movie (unique) and director (constant per group)
END;
$$ LANGUAGE plpgsql;


SELECT * FROM get_director_filmography(1);





--3
-- Calculate actor's age
-- -- Usage example:
-- SELECT first_name, last_name, birth_date, calculate_actor_age(birth_date) as age
-- FROM actors
-- WHERE birth_date IS NOT NULL;

-- Solution 1

CREATE OR REPLACE FUNCTION calculate_actor_age(birth_date DATE)
RETURNS INT AS $$
BEGIN
    RETURN DATE_PART('year', AGE(CURRENT_DATE, birth_date))::INT;
END;
$$ LANGUAGE plpgsql;

SELECT 
    first_name, 
    last_name, 
    birth_date, 
    calculate_actor_age(birth_date) AS age
FROM actors
WHERE birth_date IS NOT NULL;


-- Solution 2

SELECT * FROM actors

DROP FUNCTION get_actors_with_age


CREATE OR REPLACE FUNCTION get_actors_with_age()
RETURNS TABLE(
    actor_name TEXT,
    birth_date DATE,
    age INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.first_name || ' ' || a.last_name AS actor_name,
        a.birth_date,
        DATE_PART('year', AGE(CURRENT_DATE, a.birth_date))::INT AS age
    FROM actors a
    WHERE a.birth_date IS NOT NULL;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM get_actors_with_age();


--4
-- Check if actor has won awards
-- -- Usage example:
-- SELECT first_name, last_name, has_won_awards(actor_id) as has_awards
-- FROM actors

-- Solution 1
CREATE OR REPLACE FUNCTION has_won_awards(actor_id_param INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM actor_awards  
        WHERE actor_id = actor_id_param
    );
END;
$$ LANGUAGE plpgsql;


SELECT 
    first_name, 
    last_name, 
    has_won_awards(actor_id) AS has_awards
FROM actors;


-- Solution 2

DROP FUNCTION has_won_awards1


CREATE OR REPLACE FUNCTION has_won_awards1(actor_id_param INT)
RETURNS BOOLEAN AS $$
DECLARE
    award_count INT;
BEGIN
    SELECT COUNT(*)
    INTO award_count
    FROM actor_awards
    WHERE actor_id = actor_id_param;
    
    RETURN award_count > 0;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM has_won_awards1(2);


--Solution 3
CREATE OR REPLACE FUNCTION has_won_awards2(actor_id_param INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM actor_awards aa
        INNER JOIN awards aw ON aa.award_id = aw.award_id
        WHERE aa.actor_id = actor_id_param
    );
END;
$$ LANGUAGE plpgsql;

SELECT * FROM has_won_awards2(6);
