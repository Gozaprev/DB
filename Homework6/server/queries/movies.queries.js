export const SELECT_MOVIES = `
SELECT 
movie_id, 
title, 
release_date, 
rating,
duration_minutes,
plot_summary,
language
FROM movies;
`