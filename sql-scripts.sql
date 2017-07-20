-- CREATE TABLE imdb_test.movies(
--    id INTEGER PRIMARY KEY, -- INT differnt than INTEGER
--    name           TEXT    DEFAULT    NULL,
--    year           INTEGER  DEFAULT   NULL,
--    rank           REAL    DEFAULT    NULL
-- );

-- CREATE TABLE imdb_test.actors(
--     id INTEGER PRIMARY KEY,
--     first_name TEXT DEFAULT NULL,
--     last_name TEXT DEFAULT NULL,
--     gender TEXT DEFAULT NULL
-- );

-- CREATE TABLE imdb_test.roles(
--     actor_id INTEGER,
--     movie_id INTEGER,
--     role_name TEXT DEFAULT NULL
-- );

SELECT
  *
FROM
  movies
WHERE
  year=1990;


--------------------

SELECT
  count(*)
FROM
  movies
WHERE
  year = 1982;

-------------------

SELECT
  *
FROM
  actors
WHERE
  last_name LIKE "%stack%";

------------------

SELECT
  count(first_name) as counts,
  first_name as first
FROM
  actors
GROUP BY
  first_name
ORDER BY
  1 DESC
LIMIT
  10;
;

------------------

SELECT
  count(first_name || ' ' || last_name) as count,
  first_name || ' ' || last_name as full_name
FROM
  actors
GROUP BY
  full_name
ORDER BY
  1 DESC
LIMIT
  10
;

-----------

-- table roles is the join table
-- between movies and actors

-- and i want to know how many movies each actor was in, so I'll need to...
-- when i join
-- i get a match of movies - actors
-- then i count how many times an actor appears

SELECT
  -- roles.actor_id
  actors.id,
  count(roles.movie_id),
  actors.first_name,
  actors.last_name
FROM
  movies
INNER JOIN
  roles
ON
  movies.id = roles.movie_id
INNER JOIN
  actors
ON
  actors.id = roles.actor_id
GROUP BY
  actors.id
ORDER BY
  2 DESC
LIMIT
  100;

-----------
first, i want to know how many genres there are
SELECT
  count(movies_genres.genre),
  movies_genres.genre
FROM
  movies_genres
GROUP BY
  2
ORDER BY
  1
;

-------------
-- first, let's get the name of all actors that were in braveheart

SELECT
  actors.first_name,
  actors.last_name
FROM
  actors
INNER JOIN
  roles
ON
  actors.id = roles.actor_id
INNER JOIN
  movies
ON
  movies.id = roles.movie_id
WHERE
  movies.name = 'Braveheart' and movies.year = '1995'
ORDER BY
  2
;

-----------

 director name, the movie name, and the year
 SELECT
  directors.first_name,
  directors.last_name,
  movies.name,
  movies.year
  -- count()
FROM
  movies_genres
INNER JOIN
  movies 
ON
  movies_genres.movie_id = movies.id
INNER JOIN
  movies_directors
ON
  movies_genres.movie_id = movies_directors.movie_id
INNER JOIN
  directors
ON
  directors.id = movies_directors.director_id
WHERE
  movies_genres.genre = 'Film-Noir' and movies.year%4 = 0
ORDER BY
  3
;

-----------

first find movies kevin bacon has been in
then get all actors in those movies
and find a way to make it unique
and take out kevin bacon

feels like i might want to do a new kind of join

so if i were to use a left join
join movies to actors

SELECT
  id
FROM
  actors
WHERE
  actors.first_name = 'Kevin' and actors.last_name = 'Bacon';

i get 22591

--subquery
  --movies where bacon starred
  (
    SELECT 
      movies.id
    FROM
      movies
    JOIN
      roles
    ON
      movies.id = roles.movie_id
    WHERE 
      roles.actor_id = 22591
    )
--putting together;
-- join actors with movie ids
-- then join that with kevin movie ids

SELECT
  actors.first_name, actors.last_name, baconMovieName
FROM
  actors
JOIN
  roles
ON
  actors.id = roles.actor_id
JOIN
  (
    SELECT 
      movies.id baconMovieID, movies.name baconMovieName
    FROM
      movies
    JOIN
      roles
    ON
      movies.id = roles.movie_id
    WHERE 
      roles.actor_id = 22591
    )
  ON
    roles.movie_id = baconMovieID
  WHERE
    baconMovieName = 'Apollo 13' and actors.id != 22591
  ORDER BY
    2 DESC
    ;


  










