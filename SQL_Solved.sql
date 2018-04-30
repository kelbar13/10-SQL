USE sakila;


-- 1a. You need a list of all the actors who have Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
FROM actor
;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
ALTER TABLE actor 
ADD COLUMN actor_name VARCHAR(50);
UPDATE actor 
SET actor_name = CONCAT(first_name, ' ', last_name);
SELECT actor_name
FROM actor
;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE 'Joe'
;
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor
WHERE last_name LIKE '%GEN%'
;
-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name , first_name
;
-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan' , 'Bangladesh', 'China')
;

-- 3a. Add a middle_name column to the table actor. 
-- Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
	ADD middle_name VARCHAR(50)
    AFTER first_name
;
-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.
ALTER TABLE actor	
	MODIFY middle_name BLOB
;
-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name
;
-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name
,COUNT(*) as count
FROM actor
GROUP BY last_name
ORDER BY count DESC
;
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name
,COUNT(last_name) as count
FROM actor
GROUP BY last_name
HAVING count >= 2
;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name =  REPLACE(first_name, 'GROUCHO', 'HARPO')
WHERE last_name = 'WILLIAMS'
;
/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
 It turns out that GROUCHO was the correct name after all! 
 In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
 Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
 BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
 (Hint: update the record using a unique identifier.)*/
UPDATE actor
SET first_name =
CASE
WHEN first_name = 'HARPO' AND last_name = 'WILLIAMS'
    THEN 'GROUCHO'
WHEN first_name = 'GROUCHO' AND last_name = 'WILLIAMS'
    THEN 'MUCHO GROUCHO'
ELSE first_name
END
;
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?`PRIMARY`
CREATE TABLE IF NOT EXISTS address(
	
	address_id smallint(5) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	address VARCHAR(50),
	address2 VARCHAR(50),
	district VARCHAR(20),
	city_id SMALLINT(5) NOT NULL,
	postal_code VARCHAR(10),
	phone VARCHAR(20),
	location GEOMETRY,
	last_update TIMESTAMP
	)
;
/* 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
Use the tables staff and address:*/
SELECT s.first_name, s.last_name, a.address
FROM staff s
JOIN address a
ON s.address_id=a.address_id
;

/* 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
Use tables staff and payment. */
SELECT s.staff_id, s.first_name, s.last_name
,SUM(p.amount)as total_amount
FROM staff s
JOIN payment p
  ON s.staff_id=p.staff_id
GROUP BY s.staff_id
;
/* 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
Use inner join.*/
SELECT fa.film_id, f.title
,COUNT(fa.film_id) as actor_count
FROM film_actor fa
INNER JOIN film f
  ON fa.film_id=f.film_id
GROUP BY f.film_id
;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT i.film_id, f.title
,COUNT(f.title)as inventory_count
FROM inventory i
JOIN film f
  ON i.film_id=f.film_id
WHERE f.title='HUNCHBACK IMPOSSIBLE'
;

/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:*/
SELECT c.customer_id, c.first_name, c.last_name
,SUM(p.amount)as total_paid
FROM customer c
JOIN payment p
  ON c.customer_id=p.customer_id
GROUP BY c.customer_id
ORDER BY last_name
;
/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. */
SELECT title 
FROM film
WHERE title LIKE 'K%' OR 'Q%'
AND language_id IN
  (
  SELECT name 
  FROM language
  WHERE name = 'English'
  )
;
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id 
    FROM film_actor
    WHERE film_id IN
    (
    SELECT film_id 
    FROM film
    WHERE title='ALONE TRIP'
    )
);
    
/* 7c. You want to run an email marketing campaign in Canada, 
for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.*/
SELECT first_name, last_name, email
FROM customer 
WHERE address_id IN (
	SELECT a.address_id
    FROM address a 
    WHERE city_id IN (
    SELECT city.city_id
    FROM city
    JOIN country
    ON city.country_id=country.country_id
    WHERE country='Canada'
    )
);

/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as famiy films.*/
SELECT f.title
FROM film f
WHERE film_id IN (
	SELECT film_id
    FROM film_category 
    WHERE category_id IN (
    SELECT category_id
    FROM category c 
    WHERE name='Family'
    )
);
-- 7e. Display the most frequently rented movies in descending order.
SELECT title
, COUNT(inventory_id) AS rental_count
FROM film
JOIN inventory
USING(film_ID)
JOIN rental
USING (inventory_id)
GROUP BY title
HAVING COUNT(inventory_id) >= 10
ORDER BY COUNT(inventory_id) DESC
;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT S.store_id
, CONCAT('$',FORMAT(SUM(amount),2)) as business_in_dollars 
FROM store s
JOIN customer c
ON s.store_id=c.store_id
LEFT OUTER JOIN payment p
ON c.customer_id=p.customer_id
GROUP BY store_id
;
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, ct.country
FROM store s
JOIN address a
ON s.address_id=a.address_id
JOIN city c
ON a.city_id=c.city_id
JOIN country ct
ON c.country_id=ct.country_id
;
/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
SELECT c.name
, CONCAT('$',FORMAT(SUM(amount),2)) AS gross_revenue 
FROM category c 
JOIN film_category fc
ON c.category_id=fc.category_id
JOIN inventory i
ON fc.film_id=i.film_id
JOIN rental r
ON i.inventory_id=r.inventory_id
JOIN payment p 
ON r.rental_id=p.rental_id
GROUP BY name
ORDER BY gross_revenue DESC
LIMIT 5
;
/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.*/
CREATE VIEW top_5_genres AS
SELECT c.name
, CONCAT('$',FORMAT(SUM(amount),2)) AS gross_revenue 
FROM category c 
JOIN film_category fc
ON c.category_id=fc.category_id
JOIN inventory i
ON fc.film_id=i.film_id
JOIN rental r
ON i.inventory_id=r.inventory_id
JOIN payment p 
ON r.rental_id=p.rental_id
GROUP BY name
ORDER BY gross_revenue DESC
LIMIT 5
;
-- 8b. How would you display the view that you created in 8a?
-- Answer: Refresh the schema, select the new view
SELECT * 
FROM top_5_genres
;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top_5_genres
;
