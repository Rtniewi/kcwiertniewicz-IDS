set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;
set SQL_MODE = 'NO_ZERO_DATE';

/* *********************************************************************************************
The movie rental database model consists of several tables include information about movies,
users, and their rental behaviors.
	-- actor(actor_id, first_name, last_name)
		     --------
	-- category(category_id, name)
			    -----------
	-- country(country_id, country)
			   --------
	-- language(language_id, name)
			    -----------
	-- address(address_id, address, address2, district, city_id, postal_code, phone)
			   ----------
	-- city(city_id, city, country_id)
			-------
	-- customer(customer_id, store_id, first_name, last_name, email, address_id, active)
				-----------  --------
	-- film(film_id, title, description, release_year, language_id, rental_duration, rental_rate,
			-------
			length, replacement_cost, rating, special_features)
    -- film_actor(actor_id, film__id)
				  --------  --------
	-- rental(rental_id, rental_date, inventory_id, customer_id, return_date, staff_id)
			  ---------
	-- staff(staff_id, first_name, last_name, address_id, email, store_id, active, username, password
			 --------
	-- store(store_id, address_id)
			 --------
	-- film_category(film_id, category_id)
				    --------  -----------
	-- inventory(inventory_id, film_id, store_id)
			     ------------
	-- payment(payment_id, customer_id, staff_id, rental_id, amount, payment_date)
			   ----------
******************************************************************************************** */
-- =====
-- ACTOR
-- =====
--  altered actor to create primary key as actor_id
alter table actor
add constraint PK_constraint primary key(actor_id);

-- ========
-- CATEGORY
-- ========
-- altered category to create primary key as cateogory_id, and add name constraint on name
alter table category
add constraint PK_constraint primary key(category_id),
add constraint CHK_name check(name in ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel',
'Children', 'Drama', 'Horror', 'Action', 'Classics', 'Games', 'New', 'Documentary', 'Sports', 'Music'));

-- ========
-- COUNTRY
-- ========
-- altered country to create primary key as country_id
alter table country
add constraint PK_constraint primary key(country_id);

-- ========
-- LANGUAGE
-- ========
-- altered language to create primary key as langauge_id
alter table language
add constraint PK_constraint primary key(language_id);

-- ====
-- CITY
-- ====
-- altered city to create primary key as city_id, and added foreign key as country_id
alter table city
add constraint PK_constraint primary key(city_id),
add foreign key(country_id) references country(country_id);

-- =======
-- ADDRESS
-- =======
-- altered address to create primary key as address_id, add foreign key as city_id and  modify postal code as varchar due to postal codes sometimes using '-'
alter table address
modify postal_code varchar(50),
add constraint PK_constraint primary key(address_id),
add foreign key(city_id) references city(city_id) on delete cascade;

-- =====
-- STORE
-- =====
-- alter store to create primary key as store_id and foreign key as address_id
alter table store
add constraint PK_constraint primary key(store_id),
add foreign key(address_id) references address(address_id) on delete cascade;

-- ========
-- CUSTOMER
-- ========
-- altered customer to create primary key as customer_id, foreign keys as store_id and address_id and added constraint to check active is 0 or 1
alter table customer
add constraint PK_constriant primary key(customer_id),
add foreign key(store_id) references store(store_id) on delete cascade,
add foreign key(address_id) references address(address_id), 
add constraint CHK_active check(active = 0 or active = 1);

-- ====
-- FILM
-- ====
-- altered film to create primary key as film_id, foreign key as language_id and added check constraints on special_features,
-- rental_duration(between 2 and 8 days), rental_rate(cost beween 0.99 and 6.99), length(time of movie between 30 and 200 minutes), 
-- rating and replacement_cost(cost between 5.00 and 100.00)
alter table film
add constraint PK_constraint primary key(film_id),
add foreign key(language_id) references language(language_id) on delete cascade,
add constraint CHK_special_features check(special_features in ('Behind the Scenes', 'Commentaries', 'Deleted Scenes','Trailers')),
add constraint CHK_rental_rate check(rental_rate between 0.99 and 6.99),
add constraint CHK_length check(length between 30 and 200),
add constraint CHK_rating check(rating in ('PG', 'G', 'NC-17', 'PG-13', 'R')),
add constraint CHK_replacement_cost check(replacement_cost between 5.00 and 100.00);
-- =========
-- FILM_ACTOR
-- =========
-- altered film_actor create composite key (actor_id, film_id), and foreign keys actor_id and film_id
alter table film_actor
add constraint PK_constraint primary key(actor_id, film_id),
add foreign key(actor_id) references actor(actor_id) on delete cascade,
add foreign key(film_id) references film(film_id) on delete cascade;

-- =========
-- INVENTORY
-- =========
--  altered inventory to create primary key as inventory_id, and foreign keys film_id and store_id
alter table inventory
add constraint PK_constraint primary key(inventory_id),
add foreign key(film_id) references film(film_id) on delete cascade,
add foreign key(store_id) references store(store_id) on delete cascade;


-- =====
-- STAFF
-- =====
-- altered staff to modify email and password to varchar(100), created primary key staff_id, and foreign keys address_id and store_id
alter table staff
modify email varchar(100),
modify password varchar(100),
add constraint PK_constraint primary key(staff_id),
add foreign key(address_id) references address(address_id) on delete cascade,
add foreign key(store_id) references store(store_id) on delete cascade;

-- ======
-- RENTAL
-- ======
-- altered table rental to modfiy rental_date and return_date to datetime, created primary key rental_id, foreign keys 
-- inventory_id, customer_id, and staff_id and added unique key for rental_date, inventory_id, and customer_id
-- Due to duplicate entry for customer id '207'. I combined the unqiue keys rental_date, inventory_id, customer_id to make the keys unqiue 
alter table rental
modify return_date datetime,
modify rental_date datetime,
add constraint PK_constraint primary key(rental_id),
add foreign key(inventory_id) references inventory(inventory_id) on delete cascade,
add foreign key(customer_id) references customer(customer_id) on delete cascade,
add foreign key(staff_id) references staff(staff_id) on delete cascade,
add constraint U_constraint_rental unique key(rental_date, inventory_id, customer_id);
-- 


-- =====
-- FILM_CATEGORY
-- =====
-- altered film_category to create composite key (film_id, category_id), and foreign keys film_id and cateogry_id
alter table film_category
add constraint PK_constraint primary key(film_id, category_id),
add foreign key(film_id) references film(film_id) on delete cascade,
add foreign key(category_id) references category(category_id) on delete cascade;


-- =======
-- PAYMENT
-- =======
-- altered table payment to modfiy the payment_date to datetime, create primary key payment_id, foreign keys customer_id, staff_id, rental_id, 
-- and add check constraint to check payment amount is greater than or equal to 0
alter table payment
modify payment_date datetime,
add constraint PK_constraint primary key(payment_id),
add foreign key(customer_id) references customer(customer_id),
add foreign key(staff_id) references staff(staff_id),
add foreign key(rental_id) references rental(rental_id),
add constraint CHK_amouint check(amount >= 0);


-- 1. What is the average length of films in each category? List the results in alphabetic order of categories.
select category.name as "Movie Category", round(avg(film.length),1) as "Average Length (Minutes)"
from film join film_category on film.film_id = film_category.film_id
		  join category on film_category.category_id = category.category_id
group by category.name;


-- 2. Which categories have the longest and shortest average film lengths?

select category.name as "Movie Category", round(avg(film.length),1) as average_film_length
from film join film_category on film.film_id = film_category.film_id
		  join category on film_category.category_id = category.category_id
group by category.name
having avg(film.length) >= (
	select max(longest_average_film)
    from (select round(avg(film.length), 1) as longest_average_film
		 from film join film_category on film.film_id = film_category.film_id
				   join category on film_category.category_id = category.category_id
		 group by category.name) as subquery)
			
union

select category.name as "Movie Category", round(avg(film.length),1) as shortest_average_film
from film join film_category on film.film_id = film_category.film_id
		  join category on film_category.category_id = category.category_id
group by category.name
having avg(film.length) <= (
	select min(shortest_average_film)
    from (select round(avg(film.length), 1) as shortest_average_film
		 from film join film_category on film.film_id = film_category.film_id
				   join category on film_category.category_id = category.category_id
		 group by category.name) as subquery);
              
-- 3. Which customers have rented action but not comedy or classic movies?
select distinct concat(c.first_name, " ", c.last_name) as Name
from customer c
join rental r using (customer_id)
join inventory i using (inventory_id)
join film f using (film_id)
join film_category fc using (film_id)
join category ct using (category_id)
left join (select distinct c2.customer_id
from customer c2
join rental r2 using (customer_id)
join inventory i2 using (inventory_id)
join film f2 using (film_id)
join film_category fc2 using (film_id)
join category ct2 using (category_id)
where ct2.name = 'Comedy' and ct2.name = 'Classic') as comedy_classic using (customer_id)
where ct.name = 'Action' and comedy_classic.customer_id is null;

-- 4. Which actor has appeared in the most English-language movies?
select concat(actor.first_name, " ", actor.last_name) as "Actor that Appeared in the English-Language Movies",  count(language.name) as "Number of English-Language Movies"
from actor 
join film_actor using (actor_id)
join film using (film_id)
join language using (language_id)
where language.name = 'English'
group by actor.first_name, actor.last_name
order by count(language.name) desc
limit 1;
		

-- 5. How many distinct movies were rented for exactly 10 days from the store where Mike works?
select count(distinct rental.rental_id) as "Number of Distinct Movies rented for 10 days"
from film 
join inventory using (film_id)
join store using (store_id)
join staff using (store_id)
join rental using (staff_id)
where staff.first_name = "Mike" and datediff(return_date, rental_date) = 10;

-- 6. Alphabetically list actors who appeared in the movie with the largest cast of actors.
select  concat(actor.first_name, " ", actor.last_name) as Name, film.title as Movie, count(actor_id) as cast
from actor 
join film_actor using (actor_id)
join film using (film_id)
group by film.title
having cast >= all (
select count(actor_id)
from actor 
join film_actor using (actor_id)
join film using (film_id)
group by film.title)
order by count(actor.actor_id);

-- query prints movie with biggest cast
select film.title, count(actor.actor_id)
from actor 
join film_actor using (actor_id)
join film using (film_id)
group by film.title
order by count(actor.actor_id)desc limit 1;
