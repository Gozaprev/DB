const moviesResult = document.getElementById('result');

const fetchMovies = async () => {
    const response = await fetch('http://localhost:3000/movies');
    const movies = await response.json();

    console.log(movies)

    movies.forEach((movie) => {
        const movieElement = document.createElement('div');
        movieElement.classList.add('movie')
        movieElement.innerHTML = `
        <h3>${movie.title}</h3>
        <p>Release date: ${new Date(movie.release_date).toLocaleDateString()}</p>
        <p>Rating: ${movie.rating}</p>
        <p>Duration: ${movie.duration_minutes}</p>
        <p>Plot summary: ${movie.plot_summary}</p>
        <p>Language: ${movie.language}</p>
    `
        moviesResult.appendChild(movieElement)

    }

    );

}

// when the DOM is ready
document.addEventListener('DOMContentLoaded', async () => {
    await fetchMovies()
})