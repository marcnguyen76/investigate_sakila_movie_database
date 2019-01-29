# MARC NGUYEN
# PROGRAMMING FOR DATA SCIENCE NANODEGREE PROGRAMMING
# OCTOBER 2018
# SQL PROJECT SUBMISSION

# PROJECT QUESTION 1_1
/* We want to understand more about the movies that families are watching. 
The following categories are considered family movies: Animation, Children, 
Classics, Comedy, Family and Music. Create a query that lists each movie, 
the film category it is classified in, and the number of times it has been rented out.*/

SELECT f.title AS film_title,
       c.name AS category_name,
       COUNT(r.rental_id) AS rental_count
FROM category c 
     JOIN film_category fc 
     ON c.category_id = fc.category_id
     JOIN film f 
     ON fc.film_id = f.film_id
     JOIN inventory i 
     ON f.film_id = i.film_id
     JOIN rental r 
     ON i.inventory_id = r.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY 1, 2
ORDER BY 2;

# PROJECT QUESTION 1_2
/* Now we need to know how the length of rental duration of these family-friendly 
movies compares to the duration that all movies are rented for. Can you provide a 
table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, 
third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental 
duration for movies across all categories? Make sure to also indicate the category that these 
family-friendly movies fall into.*/

SELECT f.title AS film_title,
       c.name AS category_name,
       f.rental_duration,
       NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
FROM category c 
     JOIN film_category fc 
     ON c.category_id = fc.category_id
     JOIN film f 
     ON fc.film_id = f.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music');

# PROJECT QUESTION 1_3    
/* Finally, provide a table with the family-friendly film category, each of the quartiles, 
and the corresponding count of movies within each combination of film category for each 
corresponding rental duration category.*/

SELECT DISTINCT (category_name),
       standard_quartile,
       COUNT(category_name) OVER (PARTITION BY standard_quartile, category_name ORDER BY category_name, standard_quartile)
FROM ( 
    SELECT c.name AS category_name,
           NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
    FROM category c 
        JOIN film_category fc 
        ON c.category_id = fc.category_id
        JOIN film f 
        ON fc.film_id = f.film_id
    WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
    ORDER BY 1
    ) t1
ORDER BY 1, 2;

# CTE VERSION
WITH quartile AS ( 
    SELECT c.name AS category_name,
           NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
    FROM category c 
        JOIN film_category fc 
        ON c.category_id = fc.category_id
        JOIN film f 
        ON fc.film_id = f.film_id
    WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
    ORDER BY 1
    )

SELECT DISTINCT (category_name),
       standard_quartile,
       COUNT(category_name) OVER (PARTITION BY standard_quartile, category_name ORDER BY category_name, standard_quartile)
FROM quartile
ORDER BY 1, 2;

# PROJECT QUESTION 2.1
/* We want to find out how the two stores compare in their count of rental orders during every 
month for all the years we have data for. Write a query that returns the store ID for the store, 
the year and month and the number of rental orders each store has fulfilled for that month. 
Your table should include a column for each of the following: year, month, store ID and count 
of rental orders fulfilled during that month.*/

SELECT DATE_PART('month', r.rental_date) AS rental_month,
       DATE_PART('year', r.rental_date) AS rental_year,
       store.store_id, 
       COUNT(r.rental_id) AS count_rental
FROM store
    JOIN staff
    ON store.store_id = staff.store_id
    JOIN payment p 
    ON staff.staff_id = p.staff_id
    JOIN rental r
    ON p.rental_id = r.rental_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;


#  PROJECT QUESTION 2.2
/* We would like to know who were our top 10 paying customers, how many payments they made on a 
monthly basis during 2007, and what was the amount of the monthly payments. Can you write a query 
to capture the customer name, month and year of payment, and total payment amount for each month 
by these top 10 paying customers?*/

SELECT p.customer_id, 
       DATE_TRUNC('month', payment_date) AS pay_month, 
       c.first_name || ' ' || c.last_name AS full_name,
       COUNT(p.amount) AS pay_countpermon, 
       SUM(p.amount) AS pay_amount
FROM payment p
    JOIN customer c
    ON p.customer_id = c.customer_id 
WHERE DATE_PART('year', payment_date) = 2007
GROUP BY 1, 2, 3
HAVING p.customer_id IN (
    SELECT customerid
    FROM (
        SELECT p.customer_id AS customerid, 
            c.first_name AS first, 
            c.last_name AS last, 
            SUM(amount) AS total_amount
        FROM payment p
        JOIN customer c
        ON p.customer_id = c.customer_id 
        GROUP BY 1, 2, 3
        ORDER BY 4 DESC
        LIMIT 10 )t1
    )
ORDER BY 3, 2;



# PROJECT QUESTION 2.3
/* Finally, for each of these top 10 paying customers, I would like to find out the difference across 
their monthly payments during 2007. Please go ahead and write a query to compare the payment amounts 
in each successive month. Repeat this for each of these 10 paying customers. Also, it will be tremendously 
helpful if you can identify the customer name who paid the most difference in terms of payments.*/

SELECT pay_month,
       full_name,
       pay_amount,
       LEAD(pay_amount) OVER (ORDER BY 2, 1) - pay_amount AS lead_difference
FROM (
SELECT p.customer_id, 
       DATE_TRUNC('month', payment_date) AS pay_month, 
       c.first_name || ' ' || c.last_name AS full_name,
       COUNT(p.amount) AS pay_countpermon, 
       SUM(p.amount) AS pay_amount
FROM payment p
    JOIN customer c
    ON p.customer_id = c.customer_id 
WHERE DATE_PART('year', payment_date) = 2007
GROUP BY 1, 2, 3
HAVING p.customer_id IN (
    SELECT customerid
    FROM (
        SELECT p.customer_id AS customerid, 
            c.first_name AS first, 
            c.last_name AS last, 
            SUM(amount) AS total_amount
        FROM payment p
        JOIN customer c
        ON p.customer_id = c.customer_id 
        GROUP BY 1, 2, 3
        ORDER BY 4 DESC
        LIMIT 10 )t1
    )
ORDER BY 3, 2
) t2;

