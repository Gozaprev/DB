import express from "express";
import pg from "pg";
import config from "./database.config.js";
import { SELECT_MOVIES } from "./queries/movies.queries.js";
import cors from "cors";

const app = express();

app.use(cors());
app.use(express.json());

const PORT = 3000;
const HOST = "localhost";
const pool = new pg.Pool(config); // we have connected to our postgres database

app.get('/', (req, res) => {
    res.send('Server is live.')
});

app.get('/movies', async (req, res) => {
    console.log("1");

    try {
        const result = await pool.query(SELECT_MOVIES);
        console.log("2");
        const movies = result.rows;
        console.log("3");

        res.json(movies);
        console.log("4");
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Something went wrong.' })
    }
});

app.get('/movies/:id', async (req, res) => {
    try {
        const id = req.params.id;

        // IMPORTANT => This approach is prone to SQL injection
        // const result = await pool.query(`SELECT * FROM movies WHERE movie_id = ${id}`);

        const resultMovie = await pool.query(`SELECT * FROM movies WHERE movie_id = $1`, [id]);

        // Here we use a function
        const resultMovieName = await pool.query(`SELECT get_movie_name($1)`, [id]);
        console.log(resultMovieName.rows[0]);


        if (resultMovie.rows.length === 0) {
            return res.status(404).send({ message: `Movie with id: ${id} could not be found.` })
        }

        res.send(resultMovie.rows[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Something went wrong.' })
    }
});

// CREATE AN ENDPOINT THAT GET ACTOR DETAILS BY PROVIDED ACTOR ID
// actor_id, full_name, birth_date, biography
app.get('/actors/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await pool.query(`
             SELECT 
             actor_id, 
             CONCAT(first_name, ' ', last_name) AS full_name, 
             birth_date, 
             biography
             FROM actors
             WHERE actor_id = $1
            `, [id]);

        const [actor] = result.rows;

        if (!actor) {
            return res.status(404).send({ message: 'Actor with that id does not exist' })
        };

        res.send(actor);

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Something went wrong.' })
    }
});

app.post('/movies', async (req, res) => {
    console.log("5");
    try {
        const { title, release_date, duration_minutes, rating, director_id, plot_summary, language, budget } = req.body;

        console.log("6");
        const result = await pool.query(
            `
            INSERT INTO movies (title, release_date, duration_minutes, rating, director_id, plot_summary, language, budget)
            VALUES($1, $2, $3, $4, $5, $6, $7, $8)

            RETURNING *
            `,
            [title, release_date, duration_minutes, rating, director_id, plot_summary, language, budget]
        );

        console.log(result.rows);

        res.status(201).send({ message: 'Created', id: result.rows[0].movie_id })

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Something went wrong.' })
    }
});


/**
 * Update a movie by given ID
 * 
 * - Write an endpoint that handles update of a movie by given id
 * - Have in mind, some of the values that we would like to update might be undefined,
 * meaning the user might not have submitted value for title, and we would not want to overrider the existing title.
 */

app.put('/movies/:id', async (req, res) => {
    const id = req.params.id;
    const {
        title,
        release_date,
        duration_minutes,
        rating,
        director_id,
        plot_summary,
        language,
        budget,
    } = req.body;

    try {
        // Fetch existing movie
        const existingResult = await pool.query(
            'SELECT * FROM movies WHERE movie_id = $1',
            [id]
        );

        if (existingResult.rows.length === 0) {
            return res.status(404).json({ message: `Movie with id ${id} not found.` });
        }

        const existingMovie = existingResult.rows[0];

        // Use new values if provided, otherwise keep existing
        const updatedMovie = {
            title: title !== undefined ? title : existingMovie.title,
            release_date: release_date !== undefined ? release_date : existingMovie.release_date,
            duration_minutes: duration_minutes !== undefined ? duration_minutes : existingMovie.duration_minutes,
            rating: rating !== undefined ? rating : existingMovie.rating,
            director_id: director_id !== undefined ? director_id : existingMovie.director_id,
            plot_summary: plot_summary !== undefined ? plot_summary : existingMovie.plot_summary,
            language: language !== undefined ? language : existingMovie.language,
            budget: budget !== undefined ? budget : existingMovie.budget,
        };

        // Update the movie in DB
        const updateQuery = `
        UPDATE movies
        SET title = $1,
            release_date = $2,
            duration_minutes = $3,
            rating = $4,
            director_id = $5,
            plot_summary = $6,
            language = $7,
            budget = $8
        WHERE movie_id = $9
        RETURNING *;
      `;

        const updateValues = [
            updatedMovie.title,
            updatedMovie.release_date,
            updatedMovie.duration_minutes,
            updatedMovie.rating,
            updatedMovie.director_id,
            updatedMovie.plot_summary,
            updatedMovie.language,
            updatedMovie.budget,
            id,
        ];

        const updateResult = await pool.query(updateQuery, updateValues);

        res.json({ message: 'Movie updated successfully', movie: updateResult.rows[0] });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Something went wrong.' });
    }
});

//Solution 1
/*
app.patch('/movies/:id', async (req, res) => {
    const id = req.params.id;

  try {
    // Fetch existing movie
    const existingResult = await pool.query(
      'SELECT * FROM movies WHERE movie_id = $1',
      [id]
    );

    if (existingResult.rows.length === 0) {
      return res.status(404).json({ message: `Movie with id ${id} not found.` });
    }

    const existingMovie = existingResult.rows[0];

    // Define fields that can be updated
    const fields = [
      'title',
      'release_date',
      'duration_minutes',
      'rating',
      'director_id',
      'plot_summary',
      'language',
      'budget',
    ];

    // Build updatedMovie object by merging existing values with new ones if provided
    const updatedMovie = {};

    fields.forEach(field => {
      updatedMovie[field] = req.body[field] !== undefined ? req.body[field] : existingMovie[field];
    });

    // Update the movie in DB
    const updateQuery = `
      UPDATE movies
      SET title = $1,
          release_date = $2,
          duration_minutes = $3,
          rating = $4,
          director_id = $5,
          plot_summary = $6,
          language = $7,
          budget = $8
      WHERE movie_id = $9
      RETURNING *;
    `;

    const updateValues = [
      updatedMovie.title,
      updatedMovie.release_date,
      updatedMovie.duration_minutes,
      updatedMovie.rating,
      updatedMovie.director_id,
      updatedMovie.plot_summary,
      updatedMovie.language,
      updatedMovie.budget,
      id,
    ];

    const updateResult = await pool.query(updateQuery, updateValues);

    res.json({ message: 'Movie updated successfully', movie: updateResult.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Something went wrong.' });
  }
});
*/

app.patch('/movies/:id', async (req, res) => {
    const id = req.params.id;

  try {
    // Fetch existing movie
    const existingResult = await pool.query(
      'SELECT * FROM movies WHERE movie_id = $1',
      [id]
    );

    if (existingResult.rows.length === 0) {
      return res.status(404).json({ message: `Movie with id ${id} not found.` });
    }

    const existingMovie = existingResult.rows[0];

    // Destructure fields from request body
    const {
      title,
      release_date,
      duration_minutes,
      rating,
      director_id,
      plot_summary,
      language,
      budget,
    } = req.body;

    // Build updatedMovie object using nullish coalescing operator
    const updatedMovie = {
      title: title ?? existingMovie.title,
      release_date: release_date ?? existingMovie.release_date,
      duration_minutes: duration_minutes ?? existingMovie.duration_minutes,
      rating: rating ?? existingMovie.rating,
      director_id: director_id ?? existingMovie.director_id,
      plot_summary: plot_summary ?? existingMovie.plot_summary,
      language: language ?? existingMovie.language,
      budget: budget ?? existingMovie.budget,
    };

    // Update the movie in DB
    const updateQuery = `
      UPDATE movies
      SET title = $1,
          release_date = $2,
          duration_minutes = $3,
          rating = $4,
          director_id = $5,
          plot_summary = $6,
          language = $7,
          budget = $8
      WHERE movie_id = $9
      RETURNING *;
    `;

    const updateValues = [
      updatedMovie.title,
      updatedMovie.release_date,
      updatedMovie.duration_minutes,
      updatedMovie.rating,
      updatedMovie.director_id,
      updatedMovie.plot_summary,
      updatedMovie.language,
      updatedMovie.budget,
      id,
    ];

    const updateResult = await pool.query(updateQuery, updateValues);

    res.json({ message: 'Movie updated successfully', movie: updateResult.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Something went wrong.' });
  }
});



app.listen(PORT, HOST, () => {
    console.log(`Server is up and running at http://${HOST}:${PORT}.`)
});


