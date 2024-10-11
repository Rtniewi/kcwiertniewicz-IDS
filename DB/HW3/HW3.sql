set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

/* *********************************************************************************************
The company database model consists of several tables that allows for the tracking of company
operations, such as selling, whats contained in an order, and what customers placed orders:

	-- merchants(mid, name, city, state)
				----
	-- products(pid, name, category, description)
			    ----
	-- sell(mid, pid, price, quantity_available)
			---- ----
	-- orders(oid, shipping_method, shipping_cost)
			 ----
	-- contain(oid, pid)
			   ---- ----
	-- customers(cid, fullname, city, state)
				----
	-- place(cid, oid, order_date)
			 ---- ----'
******************************************************************************************** */

-- =========
-- CUSTOMERS
-- =========
-- altered customers primary key to cid
alter table customers 
add constraint PK_constraint primary key(cid);

-- =========
-- MERCHANTS
-- =========
-- altered merchants primary key to mid
alter table merchants
add constraint PK_constraint primary key(mid);

-- ========
-- PRODUCTS
-- ========
-- altered products primary key to pid, added name and category constraint
alter table products
add constraint PK_constraint primary key(pid),
add constraint CHK_name check(name IN ('Printer', 'Ethernet Adapter', 'Desktop', 'Hard Drive', 'Laptop', 'Router', 'Network Card', 'Super Drive', 'Monitor')),
add constraint CHK_category check(category IN ('Peripheral', 'Networking', 'Computer'));

-- ======
-- ORDERS
-- ======
-- altered orders primary key to oid, added shipping_method constraint and shipping_cost constraint
alter table orders
add constraint PK_constraint primary key(oid),
add constraint CHK_ShippingMethod check(shipping_method IN ('UPS', 'FedEx', 'USPS') and shipping_method is not null),
add constraint CHK_ShippingCost check(shipping_cost between 0 and 500);

-- ====
-- SELL
-- ====
-- altered sell to create foreign keys mid and pid, added price constraint and quantity_available constraint
alter table sell
add foreign key(mid) references merchants(mid) on delete cascade,
add foreign key (pid) references products(pid) on delete cascade,
add constraint CHK_Price check(price between 0 and 100000),
add constraint CHK_QuantityAvailable check(quantity_available between 0 and 1000);

-- =======
-- CONTAIN
-- =======
-- altered contain to create foreign keys oid and pid 
alter table contain
add foreign key(oid) references orders(oid) on delete cascade,
add foreign key (pid) references products(pid) on delete cascade;

-- =====
-- PLACE
-- =====
/* altered place to modify order_data type to DATE, create foreign keys cid and oid, 
added date constraint */
alter table place
modify order_date date,
add foreign key(cid) references customers(cid) on delete cascade,
add foreign key (oid) references orders(oid) on delete cascade,
add constraint CHK_DateValidity check(order_date like '----/--/--');


-- 1. List names and sellers of products that are no longer available (quantity=0)
select merchants.name as "Sellers of Products", products.name as "Product Names"
from merchants inner join sell on merchants.mid = sell.mid
			   inner join products on sell.pid = products.pid
where sell.quantity_available = 0
group by merchants.name, products.name;

-- 2. List names and descriptions of products that are not sold.
select products.name as "Products Names", products.description as "Descriptions of Products"
from products
where not exists (select * from sell where products.pid = sell.pid)
group by products.name, products.description;

-- 3. How many customers bought SATA drives but not any routers?
select count(*) as "Number of Distinct Customers that bought SATA drives but not routers"
from (select distinct customers.fullname
from customers inner join place on customers.cid = place.cid
			   inner join orders on place.oid = orders.oid
               inner join contain on orders.oid = contain.oid
               inner join products on contain.pid = products.pid
where products.description like '%SATA%'
and not exists(select distinct customers.fullname
from customers inner join place on customers.cid = place.cid
			   inner join orders on place.oid = orders.oid
               inner join contain on orders.oid = contain.oid
               inner join products on contain.pid = products.pid
where products.description = 'Router')) as table1;

-- 4. HP has a 20% sale on all its Networking products.
select merchants.name as "Company Name", products.name "Product Name", sell.price as "Original Price of Networking Products"
from merchants join sell on merchants.mid = sell.mid 
			   join products on sell.pid = products.pid
where merchants.name = 'HP' and products.category = 'Networking';

update sell
join merchants on merchants.mid = sell.mid
join products on sell.pid = products.pid
set sell.price = sell.price - (.20 * sell.price)
where merchants.name = 'HP' and products.category = 'Networking';

select merchants.name as "Company Name", products.name "Product Name", sell.price as "20% off HP Products"
from merchants join sell on merchants.mid = sell.mid 
			   join products on sell.pid = products.pid
where merchants.name = 'HP' and products.category = 'Networking';


-- 5. What did Uriel Whitney order from Acer? (make sure to at least retrieve product names and prices).
select customers.fullname, products.name, sell.price
from customers join place on customers.cid = place.cid
			   join orders on place.oid = orders.oid
               join contain on orders.oid = contain.oid 
               join products on contain.pid = products.pid
               join sell on products.pid = sell.pid
               join merchants on sell.mid = merchants.mid
where customers.fullname = 'Uriel Whitney' and merchants.name = 'Acer';


-- 6. List the annual total sales for each company (sort the results along the company and the year attributes).
select merchants.name as "Company", round(sum(sell.price * quantity_available),2) as "Total Sales", year(place.order_date) as "Year"
from merchants join sell on merchants.mid = sell.mid
			   join products on sell.pid = products.pid
               join contain on products.pid = contain.pid
               join orders on contain.oid = orders.oid
               join place on orders.oid = place.cid
group by merchants.name, year(place.order_date)
order by year(place.order_date);


-- 7. Which company had the highest annual revenue and in what year?
select merchants.name as "Company", round(sum(sell.price),2) as "Highest Annual Revenue", year(place.order_date) as "Year"
from merchants join sell on merchants.mid = sell.mid
			   join products on sell.pid = products.pid
               join contain on products.pid = contain.pid
               join orders on contain.oid = orders.oid
               join place on orders.oid = place.cid
group by merchants.name, sell.price, year(place.order_date)
order by sum(sell.price) desc
limit 1;


-- 8. On average, what was the cheapest shipping method used ever?
select orders.shipping_method as "Cheapest Shipping Method", round(avg(orders.shipping_cost),2) as "Cost"
from orders
group by shipping_method
order by shipping_method desc
limit 1;


-- 9. What is the best sold ($) category for each company?
with c as (select merchants.name as "Company Name", round(avg(sell.price),2) as "Revenue", 
products.category as "Best Sold Category", row_number() over (partition by merchants.name order by avg(sell.price) desc) as order_rank
from merchants join sell on merchants.mid = sell.mid
			   join products on sell.pid = products.pid
               join contain on products.pid = contain.pid
               join orders on contain.oid = orders.oid 
               join place on orders.oid = place.oid
group by merchants.name, products.category)
select *
from c
where order_rank < 2;



-- 10. For each company find out which customers have spent the most and the least amounts.
select * from(select distinct merchants.name, customers.fullname, 
round(sum(sell.price),2) as "Customers that Spent the Most and Least Amount", row_number() over (partition by merchants.name order by max(sell.price) desc) as order_rank
from merchants join sell on merchants.mid = sell.mid
			   join products on sell.pid = products.pid
               join contain on products.pid = contain.pid
               join orders on contain.oid = orders.oid
               join place on orders.oid = place.cid
               join customers on place.cid = customers.cid
group by merchants.name, customers.fullname, sell.price) c
where order_rank = 1

union

select * from(select distinct merchants.name, customers.fullname, 
round(sum(sell.price),2) as "Customers that Spent the Most and Least Amount", row_number() over (partition by merchants.name order by min(sell.price)) as order_rank
from merchants join sell on merchants.mid = sell.mid
			   join products on sell.pid = products.pid
               join contain on products.pid = contain.pid
               join orders on contain.oid = orders.oid
               join place on orders.oid = place.cid
               join customers on place.cid = customers.cid
group by merchants.name, customers.fullname, sell.price)c2
where order_rank = 1;
