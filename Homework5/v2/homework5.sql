-- Write a transaction to insert a new movie and its revenue
-- o Insert into movies table
-- o Insert into movie_revenues table
-- o If any step fails, roll back both operations

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
    -- Start transaction implicitly (PL/pgSQL automatically wraps in a transaction)
    INSERT INTO movies (title, release_date, duration_minutes, rating)
    VALUES (movie_title, release_date, duration_minutes, rating)
    RETURNING movie_id INTO movie_id_var;

    INSERT INTO movie_revenues (movie_id, domestic_revenue, international_revenue)
    VALUES (movie_id_var, domestic_revenue, international_revenue);

EXCEPTION
    WHEN OTHERS THEN
        RAISE; -- Re-raise the error (automatic rollback occurs)
END;
$$ LANGUAGE plpgsql;


SELECT insert_movie_with_revenue(
    'New Movie Title', 
    '2023-10-01'::DATE, 
    120, 
    'PG-13'::mpaa_rating, 
    1000000, 
    500000
);


SELECT *
FROM movies m
JOIN movie_revenues mr ON m.movie_id = mr.movie_id



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
    UPDATE movies
    SET budget = new_budget_value
    WHERE movie_id = target_movie_id;

    UPDATE movie_revenues
    SET 
        domestic_revenue = new_domestic_revenue_value,
        international_revenue = new_international_revenue_value
    WHERE movie_id = target_movie_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE; -- Automatic rollback on error
END;
$$ LANGUAGE plpgsql;

-- Test
SELECT update_movie_budget_and_revenue(
    15, 
    50000000, 
    150000000, 
    250000000
);

SELECT * FROM movie_revenues

SELECT * FROM movie_revenues
WHERE movie_id IN (SELECT movie_id FROM movies);



-- • Create a trigger to update 'created_at' timestamp whenever a new movie is inserted

CREATE OR REPLACE FUNCTION set_created_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop old trigger if exists
DROP TRIGGER IF EXISTS trg_set_created_at ON movies;

-- Create trigger for INSERT only
CREATE TRIGGER trg_set_created_at
BEFORE INSERT ON movies
FOR EACH ROW
EXECUTE FUNCTION set_created_at();

-- Test INSERT (not UPDATE)
INSERT INTO movies (title, release_date, duration_minutes, rating)
VALUES ('Test Movie', '2023-01-01', 90, 'PG-13');





-- • Create a trigger to prevent inserting movies with release dates in the future

CREATE OR REPLACE FUNCTION prevent_future_release_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.release_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Release date cannot be in the future (provided: %)', NEW.release_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop old trigger
DROP TRIGGER IF EXISTS trg_prevent_future_release_date ON movies;

-- Create trigger for INSERT and UPDATE
CREATE TRIGGER trg_prevent_future_release_date
BEFORE INSERT OR UPDATE ON movies
FOR EACH ROW
EXECUTE FUNCTION prevent_future_release_date();

-- Test violation
UPDATE movies SET release_date = '2026-01-01' WHERE movie_id = 1; -- Error


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

-- Test
SELECT * FROM get_movie_details(1);





-- • Create a procedure to add a new movie with its genre



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
    genre_id_var INT;
BEGIN
    -- Insert movie
    INSERT INTO movies (title, release_date, duration_minutes, rating, budget)
    VALUES (movie_title, release_date, duration_minutes, rating, budget)
    RETURNING movie_id INTO new_movie_id;

    -- Check for existing genre
    SELECT genre_id INTO genre_id_var
    FROM genres
    WHERE name = genre_name;

    -- Insert genre if missing
    IF NOT FOUND THEN
        INSERT INTO genres (name)
        VALUES (genre_name)
        RETURNING genre_id INTO genre_id_var;
    END IF;

    -- Link movie to genre
    INSERT INTO movie_genres (movie_id, genre_id)
    VALUES (new_movie_id, genre_id_var);
END;
$$;

-- Test
CALL add_new_movie(
    'New Action Movie', 
    '2023-10-01'::DATE, 
    120, 
    'PG-13'::mpaa_rating, 
    1000000, 
    'Action'
);


SELECT m.title, g.name 
FROM movies m
JOIN movie_genres mg ON m.movie_id = mg.movie_id
JOIN genres g ON mg.genre_id = g.genre_id
WHERE m.title = 'New Action Movie';

SELECT *
FROM movies
JOIN movie_genres ON movies.movie_id = movie_genres.movie_id  
JOIN genres ON movie_genres.genre_id = genres.genre_id 
WHERE movies.title = 'New Action Movie'
AND genres.name = 'Action'; 
