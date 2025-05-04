
--### Querying Production tables###

select * from production.brands

select * from production.categories

select * from production.products

select * from production.stocks

-- Here by joining all the tables we have gathered all the production data into temp1

with temp1 (store_id, product_id, product_name,brand_name,category_name,model_year,list_price,quantity)
as
(
select s.store_id,p.product_id, p.product_name,b.brand_name, c.category_name,p.model_year,p.list_price,s.quantity
from production.products p
inner join production.brands b
on p.brand_id=b.brand_id
inner join production.categories c
on p.category_id=c.category_id
inner join production.stocks s
on p.product_id=s.product_id
)

select distinct store_id,product_id from temp1

-- We are creating a VIEW to query data that display results dynamically from underlying tables

--DROP VIEW VW_ProductDetails 

CREATE VIEW VW_ProductDetails (store_id, product_id, product_name,brand_id,brand_name,category_id,category_name,model_year,list_price,quantity)
as
select s.store_id,p.product_id, p.product_name,b.brand_id,b.brand_name,c.category_id, c.category_name,p.model_year,p.list_price,s.quantity
from production.products p
inner join production.brands b
on p.brand_id=b.brand_id
inner join production.categories c
on p.category_id=c.category_id
inner join production.stocks s
on p.product_id=s.product_id

select * from VW_ProductDetails V_PD

--Total number of products in each store

select distinct count(V_PD.product_id) as Tot_Products,V_PD.store_id
from VW_ProductDetails V_PD 
group by V_PD.store_id

--Total number of products in each store in each year
select distinct count(V_PD.product_id) as Tot_ProductsPerYr,V_PD.store_id,V_PD.model_year
from VW_ProductDetails V_PD 
group by V_PD.store_id,V_PD.model_year
order by V_PD.store_id

--Total Production of each brand in each year in each store
select V_PD.store_id,V_PD.brand_id,V_PD.model_year, SUM(V_PD.quantity) as TotalQtyPerBrand
from VW_ProductDetails V_PD 
group by V_PD.brand_id,V_PD.store_id,V_PD.model_year
order by V_PD.store_id, V_PD.brand_id, V_PD.model_year

select V_PD.store_id,V_PD.product_id,V_PD.product_name,V_PD.brand_id,V_PD.brand_name,V_PD.category_id,V_PD.category_name,V_PD.model_year,V_PD.list_price,V_PD.quantity
from VW_ProductDetails V_PD
where V_PD.store_id=1


--### Querying Sales tables###

Select * from sales.customers

Select * from sales.orders

Select * from sales.order_items

Select * from sales.staffs

Select * from sales.stores

--Querying orders from distinct customers

select count(distinct sales.orders.customer_id )
from sales.orders --1445
--We found that almost all the customers ordered the products

select distinct sales.orders.order_status
from sales.orders
--There are 4 types of order status which are not defined in any tables.

select distinct o.order_id,o.*,c.city,c.state
from sales.orders o
inner join sales.customers c
on o.customer_id=c.customer_id
where o.store_id=1 --CA
order by o.order_id
-- Here we got the orders that are ordered from store_id = 1 and they are 348 distinct customers who ordered them.

select o.order_id,o.*,c.city,c.state
from sales.orders o
inner join sales.customers c
on o.customer_id=c.customer_id
where o.store_id=2 --NY
order by o.order_id
-- Here we got the orders that are ordered from store_id = 2 and they are 1093 distinct customers who ordered them.

select o.order_id,o.*,c.city,c.state
from sales.orders o
inner join sales.customers c
on o.customer_id=c.customer_id
where o.store_id=3 --TX
order by o.order_id
-- Here we got the orders that are ordered from store_id = 3 and they are 174 distinct customers who ordered them.

select distinct c.city
from sales.orders o
inner join sales.customers c
on o.customer_id=c.customer_id
where o.store_id=1
order by c.city
-- There are orders from 40 cities in CA for the store 1.

select distinct c.city
from sales.orders o
inner join sales.customers c
on o.customer_id=c.customer_id
where o.store_id=2
order by c.city
-- There are orders from 134 cities in NY for the store 2.

select distinct c.city
from sales.orders o
inner join sales.customers c
on o.customer_id=c.customer_id
where o.store_id=3
order by c.city
-- There are orders from 21 cities in TX for the store 3.

select distinct item_id, order_id
from sales.order_items
order by order_id

select o.order_id,oi.item_id, c.customer_id,s.staff_id,o.order_date
from sales.order_items oi
inner join sales.orders o
on oi.order_id = o.order_id
inner join sales.customers c
on o.customer_id=c.customer_id
inner join sales.stores st
on o.store_id=st.store_id
inner join sales.staffs s
on st.store_id=s.store_id

select o.order_id,
oi.item_id, 
c.customer_id,st.store_id,
s.staff_id,
o.order_date,
oi.list_price,
oi.discount
from sales.customers c
inner join sales.orders o 
on c.customer_id=o.customer_id
inner join sales.order_items oi
on o.order_id=oi.order_id
inner join sales.stores st
on o.store_id=st.store_id
inner join sales.staffs s
on o.staff_id=s.staff_id
where o.order_id=1

--DROP VIEW VW_SalesDetails
Create VIEW VW_SalesDetails(order_id,product_id,item_id,customer_id,store_id,staff_id,order_date,list_price,discount)
as
select o.order_id,
oi.product_id,
oi.item_id, 
c.customer_id,
st.store_id,
s.staff_id,
o.order_date,
oi.list_price,
oi.discount
from sales.customers c
inner join sales.orders o 
on c.customer_id=o.customer_id
inner join sales.order_items oi
on o.order_id=oi.order_id
inner join sales.stores st
on o.store_id=st.store_id
inner join sales.staffs s
on o.staff_id=s.staff_id
--where o.order_id=1

Select * from VW_SalesDetails

--####Getting sales details and production details together:
Create VIEW VW_ProductNSales (order_id,
item_id,
product_id,
product_name,
brand_name,
category_name,
model_year,
customer_id,
store_id,
staff_id,
order_date,
list_price,
discount,
quantity)
AS
select o.order_id,
oi.item_id,
oi.product_id,
p.product_name,
b.brand_name,
ca.category_name,
p.model_year,
c.customer_id,
st.store_id,
s.staff_id,
o.order_date,
oi.list_price,
oi.discount,
sto.quantity
from sales.customers c
inner join sales.orders o 
on c.customer_id=o.customer_id
inner join sales.order_items oi
on o.order_id=oi.order_id
inner join sales.stores st
on o.store_id=st.store_id
inner join sales.staffs s
on o.staff_id=s.staff_id
inner join production.products p
on oi.product_id=p.product_id
inner join production.brands b
on p.brand_id=b.brand_id
inner join production.categories ca
on p.category_id=ca.category_id
inner join production.stocks sto
on st.store_id=sto.store_id and p.product_id = sto.product_id
--where o.order_id=1


select * from VW_ProductNSales

--Verification of same query with individual queries

--Sales Details
select o.order_id,
oi.product_id,
oi.item_id, 
c.customer_id,
st.store_id,
s.staff_id,
o.order_date,
oi.list_price,
oi.discount
from sales.customers c
inner join sales.orders o 
on c.customer_id=o.customer_id
inner join sales.order_items oi
on o.order_id=oi.order_id
inner join sales.stores st
on o.store_id=st.store_id
inner join sales.staffs s
on o.staff_id=s.staff_id
where o.order_id=2

--Product Details
select s.store_id,p.product_id, p.product_name,b.brand_name, c.category_name,p.model_year,p.list_price,s.quantity
from production.products p
inner join production.brands b
on p.brand_id=b.brand_id
inner join production.categories c
on p.category_id=c.category_id
inner join production.stocks s
on p.product_id=s.product_id
where p.product_id in (20,16)
and s.store_id=2
