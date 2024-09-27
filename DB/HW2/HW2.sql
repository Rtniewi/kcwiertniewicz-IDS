/* ****************************************************************************************
Katrina Cwiertniewicz 
9/26/2024
DB Assignment 2
**************************************************************************************** */

set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

use assignment2

-- date_sold modified to DATE data type
alter table serves modify date_sold DATE;

-- altered chefs primary key to chefID
alter table chefs
add constraint PK_constraint primary key(chefID);

-- altered restaurants primary key to restID
alter table restaurants
add constraint PK_constraint primary key(restID);

-- altered foods primary key to foodID
alter table foods
add constraint PK_constraint primary key(foodID);

-- altered works to avoid duplicate (chefID,restID) combinations
alter table works
add unique(chefID,restID);

-- altered works to create foreign key for chefID and restID
alter table works
add foreign key(chefID) references chefs(chefID) on delete cascade,
add foreign key(restID) references restaurants(restID) on delete cascade;


-- altered serves to avoid duplicate (restID,foodID) combinations
alter table serves 
add unique(restID,foodID);

-- altered serves to create foreign key for restID and foodID
alter table serves
add foreign key(restID) references restaurants(restID) on delete cascade,
add foreign key(foodID) references foods(foodID) on delete cascade;


-- Average Price of Foods at Each Restaurant
select restaurants.name as "Restaurant Name", avg(foods.price) as "Average Food Price"
from foods join serves on foods.foodID = serves.foodID
		   join restaurants on serves.restID = restaurants.restID
group by restaurants.name
order by avg(foods.price);


-- Maximum Food Price at Each Restaurant
select restaurants.name as "Restaurant Name", max(foods.price) as "Maximum Food Price"
from foods join serves on foods.foodID = serves.foodID
		   join restaurants on serves.restID = restaurants.restID
group by restaurants.name
order by max(foods.price) desc;


-- Count of Different Food Types Served at Each Restaurant
select restaurants.name as "Restaurant Name", count(foods.type) as "Types of Food"
from foods join serves on foods.foodID = serves.foodID
		   join restaurants on serves.restID = restaurants.restID
group by restaurants.name
order by restaurants.name;


-- Average Price of Foods Served by Each Chef
select chefs.name as "Chef Name", avg(foods.price) as "Average Food Price"
from foods join serves on foods.foodID = serves.foodID
		   join restaurants on serves.restID = restaurants.restID
           join works on restaurants.restID = works.restID
           join chefs on works.restID = chefs.chefID
group by chefs.name
order by avg(foods.price);

-- Find the Restaurant with the Highest Average Food Price
select restaurants.name as "Restaurant Name", avg(foods.price) as "Average Food Price"
from foods join serves on foods.foodID = serves.foodID
		   join restaurants on serves.restID = restaurants.restID
group by restaurants.name
having avg(foods.price) >= all (
	select avg(foods.price)
    from foods
    join serves on foods.foodID = serves.foodID
    join restaurants on serves.restID = restaurants.restID
	group by restaurants.name
);

-- Determine which chef has the highest average price of the foods served at the restaurants where they work. 
-- Include the chef's name, the average food price, and the names of the restaurants where the chef works.
-- Sort the results by the average food price in descending order. 

select chefs.name as "Chef Name", avg(foods.price) as "Average Food Price", restaurants.name as "Resturants Where They Work"
from chefs join works on chefs.chefID = works.chefID
		   join restaurants on works.restID = restaurants.restID
           join serves on restaurants.restID = serves.restID
           join foods on serves.foodID = foods.foodID
group by chefs.name, restaurants.name
order by avg(foods.price) desc;

