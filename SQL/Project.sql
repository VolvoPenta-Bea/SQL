/*Let's start with creating a table that provides the following details: actor's first and last name combined as full_name, film title, film description and length of the movie. How many rows are there in the table?*/
SELECT CONCAT(a.first_name,' ',a.last_name)AS full_name, title film_title, description description, length length_movie
FROM film f
JOIN film_actor fa ON fa.film_id = f.film_id
JOIN actor a ON a.actor_id = fa.actor_id
ORDER BY full_name;

/*Write a query that creates a list of actors and movies where the movie length was more than 60 minutes. How many rows are there in this query result?*/
SELECT CONCAT(a.first_name,' ',a.last_name)AS full_name, title film_title, description description, length length_movie
FROM film f
JOIN film_actor fa ON fa.film_id = f.film_id
JOIN actor a ON a.actor_id = fa.actor_id
WHERE f.length > 60; /*note what is questioned greater than only not greater or equal to*/

/*Write a query that captures the actor id, full name of the actor, and counts the number of movies each actor has made. (HINT: Think about whether you should group by actor id or the full name of the actor.) Identify the actor who has made the maximum number movies.*/
SELECT a.actor_id actor_id, CONCAT(a.first_name,' ',a.last_name)AS full_name, COUNT(f.title) count_movies
FROM film f
JOIN film_actor fa ON fa.film_id = f.film_id
JOIN actor a ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY count_movies DESC;

/*Write a query that displays a table with 4 columns: actor's full name, film title, length of movie, and a column name "filmlen_groups" that classifies movies based on their length. Filmlen_groups should include 4 categories: 1 hour or less, Between 1-2 hours, Between 2-3 hours, More than 3 hours*/
SELECT CONCAT(a.first_name,' ',a.last_name) AS full_name, 
	f.title film_title, 
	f.length length_of_movie, 
	CASE WHEN f.length > 180 THEN 'More than 3 hours'
	WHEN f.length BETWEEN 120 AND 180 THEN 'Between 2-3 hours'
	WHEN f.length BETWEEN 60 AND 120 THEN 'Bewteen 1-2 hours'
	 ELSE '1 hour or less' END AS filmlen_groups
FROM film f
JOIN film_actor fa ON fa.film_id = f.film_id
JOIN actor a ON a.actor_id = fa.actor_id
GROUP BY 1, 2, 3
ORDER BY film_title;


/*Now, we bring in the advanced SQL query concepts! Revise the query you wrote above to create a count of movies in each of the 4 filmlen_groups: 1 hour or less, Between 1-2 hours, Between 2-3 hours, More than 3 hours.*/

/*Wrong but expected wrong

Because I kept the actors name I got a longer list because there are several actors in one film. The question asked for each movie. I can double check the answer against the list of films. It should be equally long - 1000 films */

SELECT filmlen_groups, 
	COUNT (CASE filmlen_groups 
		   WHEN 'than 3 hours'THEN 1
		   WHEN 'Between 2-3 hours'THEN 1
		   WHEN 'Bewteen 1-2 hours'THEN 1
		   WHEN '1 hour or less' THEN 1
		  ELSE 0 END) count_filmlengroups
FROM 
	(SELECT CONCAT(a.first_name,' ',a.last_name) AS full_name, 
		f.title film_title, 
		f.length length_of_movie, 
		CASE WHEN f.length > 180 THEN 'More than 3 hours'
		WHEN f.length > 120 AND f.length <= 180 THEN 'Between 2-3 hours'
		WHEN f.length > 60 AND f.length <= 120 THEN 'Between 1-2 hours'
		 ELSE '1 hour or less' END AS filmlen_groups
	FROM film f
	JOIN film_actor fa ON fa.film_id = f.film_id
	JOIN actor a ON a.actor_id = fa.actor_id
	GROUP BY 1, 2, 3
	ORDER BY film_title) AS filmlen_groups2
GROUP BY 1;


/*Right

Double check by running 
SELECT COUNT(title) count_title
FROM film;

= 1000
*/
SELECT    DISTINCT(filmlen_groups), /*Important to have exclusive rows*/
		  COUNT(title) OVER (PARTITION BY filmlen_groups) AS filmcount_bylencat /*By using a window function we dont have to repeat the case, window has access to that*/
FROM  
		 (SELECT title,length,
		  CASE WHEN length <= 60 THEN '1 hour or less'
		  WHEN length > 60 AND length <= 120 THEN 'Between 1-2 hours'
		  WHEN length > 120 AND length <= 180 THEN 'Between 2-3 hours'
		  ELSE 'More than 3 hours' END AS filmlen_groups
		  FROM film ) t1
ORDER BY  filmlen_groups;

/*My way right answer*/
SELECT filmlen_groups, 
	COUNT (CASE filmlen_groups 
		   WHEN 'than 3 hours'THEN 1
		   WHEN 'Between 2-3 hours'THEN 1
		   WHEN 'Bewteen 1-2 hours'THEN 1
		   WHEN '1 hour or less' THEN 1
		  ELSE 0 END) count_filmlengroups
FROM 
	(SELECT  
		title film_title, 
		length length_of_movie, 
		CASE WHEN length > 180 THEN 'More than 3 hours'
		WHEN length > 120 AND length <= 180 THEN 'Between 2-3 hours'
		WHEN length > 60 AND length <= 120 THEN 'Between 1-2 hours'
		 ELSE '1 hour or less' END AS filmlen_groups
	FROM film
	ORDER BY film_title) AS filmlen_groups2
GROUP BY 1
ORDER BY filmlen_groups;