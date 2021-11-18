-- Lab | SQL Subqueries
use sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

select film_id, count(inventory_id) from inventory
where film_id = (select film_id from film where title = 'Hunchback Impossible')
group by film_id;

-- 2. List all films whose length is longer than the average of all the films.

select film_id, title, length from film
where length > (select avg(length) from film)
order by length asc;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

select actor_id, first_name, last_name from actor
LEFT join film_actor fa using(actor_id)
where film_id = (select film_id from film where title = 'Alone Trip');

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

select title from film
left join film_category using (film_id)
where category_id = (select category_id from category where name = 'Family');

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, 
-- you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.


select * from address;

select first_name, last_name, email from customer
left join address a using (address_id)
left join city c on a. city_id = c.city_id
left join country ca on c.country_id = ca.country_id
where ca.country_id = (select country_id from country where country = 'Canada');




-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

select actor_id  from (
	select *, row_number() over ( order by number_of_films desc) ranking from (
		select actor_id, count(film_id) as number_of_films from film_actor
		left join film using(film_id)
		group by actor_id
		order by 2 asc) sub1
        )sub2
where ranking = 1;

select title from film
left join film_actor using (film_id)
where actor_id = (select actor_id  from (
	select *, row_number() over ( order by number_of_films desc) ranking from (
		select actor_id, count(film_id) as number_of_films from film_actor
		left join film using(film_id)
		group by actor_id
		order by 2 asc) sub1
        )sub2
where ranking = 1);

-- 7. Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

select customer_id from (
	select *, row_number() over (order by suma desc) ranking from (
		select customer_id, sum(amount) as suma from customer
        left join payment using(customer_id)
		group by 1
		order by 2 desc) sub1
        )sub2
where ranking = 1;

select title from film
left join inventory i using (film_id)
left join rental r on i.inventory_id = r.inventory_id
left join customer c on r.customer_id = c.customer_id
where c.customer_id = (select customer_id from (
	select *, row_number() over (order by suma desc) ranking from (
		select customer_id, sum(amount) as suma from customer
        left join payment using(customer_id)
		group by 1
		order by 2 desc) sub1
        )sub2
where ranking = 1);

-- 8. Customers who spent more than the average payments.

select customer_id, amount from customer
left join payment using ( customer_id)
where amount > (select avg(amount) from payment);