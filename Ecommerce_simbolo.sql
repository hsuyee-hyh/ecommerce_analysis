############################ Customer Demographic Analysis ********************
# average age of customer by gender based on registration source
SELECT registration_source,
	round(avg(age),0) as average_age
FROM customers
GROUP BY registration_source;


# Which registration source has the highest number of customer registrations?
SELECT 	
	registration_source,
    count(customer_id) as no_of_customer_registrations
FROM customers
GROUP BY registration_source
ORDER BY no_of_customer_registrations desc;

##################################### Product Performance Analysis ########################3
#Which product category generates the most revenue per year? (revenue (with discount or without discount))
with OrderCTE as (
SELECT o.*,
	round(total_amount - (total_amount* (discount/100)),2) as discounted_amount,
    oi.order_id as oi_order_id,
    oi.product_id
FROM orders o
LEFT JOIN order_items oi
	on o.order_id = oi.order_id
)
#select * from OrderCTE where discounted_amount is null;

SELECT p.category
	, extract(year from c.order_date) as order_year
	, sum(c.discounted_amount) as total_revenue
FROM products p
LEFT JOIN OrderCTE c
	ON p.product_id = c.product_id
GROUP BY p.category, order_year
ORDER BY p.category asc, order_year asc,total_revenue desc;

# finding : product_id>50 don't have orders yet
select p.product_id, o.product_id from products p
left join order_items o
	on p.product_id = o.product_id;
    
select *
from products
where product_id > 50;


# Identify top 5 products with the highest sale volume
SELECT p.product_id,
	p.product_name,
    p.category,
	sum(quantity) as total_sale_volume
FROM order_items o
LEFT JOIN products p
	on o.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_sale_volume desc
LIMIT 5;

# How does the stock quantity has for each product for last 6 months?
SELECT product_name,
	sum(stock_quantity) as total_stock_quantity
FROM products
WHERE date(created_at) <= current_date() and 
	  date(created_at) >= date_sub( date_add(current_date(), INTERVAL -6 MONTH), interval Day(current_date())-1 DAY)
GROUP BY product_name
ORDER BY total_stock_quantity desc;


###################################### Order Trend Analysis #########################
# What is the monthly trend of total order amounts per month?
with MonthlyOrderAmount as (
select monthname(order_date) as 'month_name',
	sum(total_amount) as current_order_amount,
    lag(sum(total_amount)) over (order by extract(month from order_date)) as previous_month_order_amount
from orders
GROUP BY month_name, extract(month from order_date)
ORDER BY extract(month from order_date)
)
select * 
	, round(((current_order_amount - previous_month_order_amount)/previous_month_order_amount)*100,2) as 'MoM (%)'
from MonthlyOrderAmount;



select current_date(),date_add(current_date(), INTERVAL -6 MONTH) as last_6_months
	, date_sub( date_add(current_date(), INTERVAL -6 MONTH), interval Day(current_date())-1 DAY) as first_day_of_last_6_months
    , date(created_at)
from products;

select * from products;
select * from order_items;

select distinct extract(year from order_date) from orders;
select * from orders where order_date is null;
select * from order_items;
select order_id, count(*) from order_items group by order_id having count(*)>1;

select * from customers;

select * 
from Information_schema.columns
where table_schema = 'simbolo_ecommerce'
and column_name like '%product%';
