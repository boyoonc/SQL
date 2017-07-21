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
-- first, i want to know how many genres there are
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

 -- director name, the movie name, and the year
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

-- first find movies kevin bacon has been in
-- then get all actors in those movies
-- and find a way to make it unique
-- and take out kevin bacon

-- feels like i might want to do a new kind of join

-- so if i were to use a left join
-- join movies to actors

SELECT
  id
FROM
  actors
WHERE
  actors.first_name = 'Kevin' and actors.last_name = 'Bacon';

-- i get 22591

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
    -- baconMovieName = 'Apollo 13' and actors.id != 22591
    actors.id != 22591
  ORDER BY
    3 DESC
    ;

-- oh no i forgot about the drama genre!
-----------
--ta's answer

SELECT *, a.first_name || " " || a.last_name AS full_name
FROM actors AS a
  INNER JOIN roles AS r ON r.actor_id = a.id
  INNER JOIN movies AS m ON r.movie_id = m.id
  INNER JOIN movies_genres AS mg
    ON mg.movie_id = m.id
    AND mg.genre = 'Drama'
WHERE m.id IN (
  SELECT m2.id
  FROM movies AS m2
    INNER JOIN roles AS r2 ON r2.movie_id = m2.id
    INNER JOIN actors AS a2
      ON r2.actor_id = a2.id
      AND a2.first_name = 'Kevin'
      AND a2.last_name = 'Bacon'
)
AND full_name != 'Kevin Bacon'
and m.name = 'Apollo 13'
ORDER BY a.last_name ASC;
  
SELECT *, a.first_name || " " || a.last_name AS full_name
FROM actors AS a
  INNER JOIN roles AS r ON r.actor_id = a.id
  INNER JOIN movies AS m ON r.movie_id = m.id
  INNER JOIN movies_genres AS mg
    ON mg.movie_id = m.id
    AND mg.genre = 'Drama'
WHERE m.id IN (
    SELECT 
      movies.id baconMovieID
    FROM
      movies
    JOIN
      roles
    ON
      movies.id = roles.movie_id
    WHERE 
      roles.actor_id = 22591
)
-- AND full_name != 'Kevin Bacon'
and m.name = 'Apollo 13'
ORDER BY a.last_name ASC;


----------------
SELECT actors.first_name, actors.last_name
FROM (SELECT
roles.actor_id
FROM movies
JOIN roles
ON roles.movie_id = movies.id
WHERE movies.year >2000
INTERSECT
SELECT
roles.actor_id
FROM movies
JOIN roles
ON roles.movie_id = movies.id
WHERE movies.year <1900) a
JOIN actors
ON a.actor_id = actors.id
;
----------------
--actors that had five or more distinct (cough cough) roles in the same movie.
--returns the actors' names, the movie name, and the number of distinct roles that they played in that movie 

-- need actors' role per movie
-- usually should be 1
-- so then in roles table, how many rows are there with the same values

SELECT
  -- count(roles.actor_id) c
  count(DISTINCT roles.role) c, actors.first_name, actors.last_name, movies.name
FROM
  roles
JOIN actors ON actors.id = roles.actor_id
JOIN
  movies
ON
  roles.movie_id = movies.id
WHERE movies.year > 1990
-- AND c > 4 -- can't do this with aggregate method
GROUP BY
  roles.movie_id, roles.actor_id
HAVING c > 4;

-----------------
-- For each year, count the number of movies in that year that had only female actors
-- select movies with males
-- select with no males
-- select with females
-- group!

-- small chunk:
(SELECT
  movies.id
FROM
  movies
JOIN
  roles
ON
  movies.id = roles.movie_id
JOIN
  actors
ON actors.id = roles.actor_id
WHERE
  actors.gender = M)


-- full answer:
SELECT
  movies.year, count(movies.id)
FROM
  movies
where
  movies.id not in(
    SELECT
      movies.id
    FROM
      movies
    JOIN
      roles
    ON
      movies.id = roles.movie_id
    JOIN
      actors
    ON actors.id = roles.actor_id
    WHERE
      actors.gender = 'M'
    )
and movies.id in(
    SELECT
      movies.id
    FROM
      movies
    JOIN
      roles
    ON
      movies.id = roles.movie_id
    JOIN
      actors
    ON actors.id = roles.actor_id
    WHERE
      actors.gender = 'F'
)
GROUP BY
  movies.year;






