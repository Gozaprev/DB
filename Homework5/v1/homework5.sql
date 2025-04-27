-- Write a transaction to insert a new movie and its revenue
-- o Insert into movies table
-- o Insert into movie_revenues table
-- o If any step fails, roll back both operations

--I wanted to exercise more functions :)

CREATE OR REPLACE FUNCTION insert_movie_with_revenue(
    movie_title VARCHAR,
    release_date DATE,
    duration_minutes INT,
    rating mpaa_rating,
    domestic_revenue NUMERIC,
	international_revenue NUMERIC
) RETURNS VOID AS $$
DECLARE
    movie_id_var INT;
BEGIN
    -- Start of the transaction
    -- BEGIN;

    -- Insert into movies table
    INSERT INTO movies (title, release_date, duration_minutes, rating)
    VALUES (movie_title, release_date, duration_minutes, rating)
    RETURNING movie_id INTO movie_id_var;  

    -- Insert into movie_revenues table
    INSERT INTO movie_revenues (movie_id, domestic_revenue, international_revenue)
    VALUES (movie_id_var, domestic_revenue, international_revenue);  

    -- Commit of the transaction
    -- COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        -- Rollback the transaction in case of an error
        --ROLLBACK;
        RAISE;  -- Re-raise the error for further handling
END;
$$ LANGUAGE plpgsql;


SELECT insert_movie_with_revenue('New Movie Title', '2023-10-01'::DATE, 120, 'PG-13', 1000000, 500000);


-- Write a transaction to update movie budget and revenue
-- o Update movie budget
-- o Update revenue
-- o Ensure both updates succeed or none

CREATE OR REPLACE FUNCTION update_movie_budget_and_revenue(
    target_movie_id INT,
    new_budget_value NUMERIC,
    new_domestic_revenue_value NUMERIC,
    new_international_revenue_value NUMERIC
) RETURNS VOID AS $$
BEGIN
    -- Step 1: Update movie budget
    UPDATE movies
    SET budget = new_budget_value
    WHERE movie_id = target_movie_id;

    -- Step 2: Update revenue
    UPDATE movie_revenues
    SET domestic_revenue = new_domestic_revenue_value,
        international_revenue = new_international_revenue_value
    WHERE movie_id = target_movie_id;

EXCEPTION
    WHEN OTHERS THEN
        -- ROLLBACK
        RAISE;
END;
$$ LANGUAGE plpgsql;


SELECT update_movie_budget_and_revenue(
    15,            -- target_movie_id
    50000000,       -- new_budget_value
    150000000,      -- new_domestic_revenue_value
    250000000       -- new_international_revenue_value
);


-- • Create a trigger to update 'created_at' timestamp whenever a new movie is inserted
CREATE OR REPLACE FUNCTION set_created_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_created_at
BEFORE INSERT ON movies
FOR EACH ROW
EXECUTE FUNCTION set_created_at();

UPDATE movies
SET title = 'Inception1' 
WHERE movie_id = 1;

DROP TRIGGER trg_set_created_at ON movies

SELECT * 
FROM movies
WHERE title = 'Inception1' 

-- • Create a trigger to prevent inserting movies with release dates in the future
-- 1. Create the trigger function
CREATE OR REPLACE FUNCTION prevent_future_release_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.release_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Release date % cannot be in the future.', NEW.release_date;
		--'Cannot insert a movie with a future release date (%).', NEW.release_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Create the trigger
CREATE TRIGGER trg_prevent_future_release_date
BEFORE INSERT ON movies
FOR EACH ROW
EXECUTE FUNCTION prevent_future_release_date();

DROP TRIGGER IF EXISTS trg_prevent_future_release_date ON movies;


CREATE TRIGGER trg_prevent_future_release_date
BEFORE INSERT OR UPDATE ON movies
FOR EACH ROW
EXECUTE FUNCTION prevent_future_release_date();

UPDATE movies
SET release_date = '2026-01-01' 
WHERE movie_id = 1;

SELECT *
FROM pg_trigger
WHERE tgrelid = 'movies'::regclass;

-- • Create a function that returns movie details as a row type
CREATE OR REPLACE FUNCTION get_movie_details(p_movie_id INT)
RETURNS movies AS $$
DECLARE
    result movies%ROWTYPE;
BEGIN
    SELECT * INTO result
    FROM movies
    WHERE movie_id = p_movie_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_movie_details(1);


-- • Create a procedure to add a new movie with its genre
SELECT * FROM genres

CREATE OR REPLACE PROCEDURE add_new_movie(
    movie_title VARCHAR,
    release_date DATE,
    duration_minutes INT,
    rating mpaa_rating,
    budget NUMERIC,
    genre_name VARCHAR
)
LANGUAGE plpgsql AS $$
DECLARE
    new_movie_id INT;
    genre_id INT;
BEGIN
    -- Insert into movies table
    INSERT INTO movies (title, release_date, duration_minutes, rating, budget)
    VALUES (movie_title, release_date, duration_minutes, rating, budget)
    RETURNING movie_id INTO new_movie_id;  

    -- Check if the genre already exists
    genre_id := NULL;
    SELECT genre_id INTO genre_id
    FROM genres
    WHERE name = genre_name;

    -- If the genre does not exist, insert it
    IF genre_id IS NULL THEN
        INSERT INTO genres (name)
        VALUES (genre_name)
        RETURNING genre_id INTO genre_id;  -- Capture the new genre_id
    END IF;

    -- Insert into movie_genres table
    INSERT INTO movie_genres (movie_id, genre_id)
    VALUES (new_movie_id, genre_id);
END;
$$;

DROP PROCEDURE IF EXISTS add_new_movie;


CALL add_new_movie('New Movie Title', '2023-10-01'::DATE, 120, 'PG-13', 1000000, 'Action');

SELECT *
FROM movies
JOIN movie_genres ON movies.movie_id = movie_genres.movie_id  
JOIN genres ON movie_genres.genre_id = genres.genre_id 
WHERE movies.title = 'New Movie Title'
AND genres.name = 'Action'; 
