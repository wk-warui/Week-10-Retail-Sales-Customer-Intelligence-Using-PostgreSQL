show search_path;

set search_path to public;

select * from customers limit 5;
select * from orders limit 5;


--SECTION A — SQL fundamentals (Q1–Q10)

-- Q1: Retrieve all customer records.
select * from customers;

-- Q2: Display customer names, cities, and segments.
select customer_name, city, customer_segment
from customers;

-- Q3: Find customers living in Nairobi.
select customer_name, city
from customers
where city = 'Nairobi';

-- Q4: Find customers registered after January 1, 2025.
select customer_name, registration_date
from customers
where registration_date > '2025-1-1'
order by registration_date;

-- Q5: Display all unique customer cities.
select distinct city from customers;

-- Q6: Retrieve the 10 most recent orders.
select * from orders
order by order_date desc
limit 10;

-- Q7: Find orders with unit prices above KSh 10,000.
select * from orders;

select order_id, product_name, unit_price
from orders
where unit_price > 10000
order by unit_price;

-- Q8: Find customers whose names start with A.
select * from customers;

select customer_name
from customers
where customer_name like 'A%';

-- Q9: Retrieve orders with quantities between 2 and 5.
select * from orders;

select order_id, product_name, quantity
from orders
where quantity between 2 and 5;

-- Q10: Find orders paid through M-Pesa.
select * from orders;

select order_id, payment_method
from orders
where payment_method = 'M-Pesa';


-- Section B — Aggregation and grouping (Q11–Q20)

-- Q11: Count all customers.
select * from customers;

select count(customer_id) from customers;

-- Q12: Count all orders.
select * from orders;

select count(order_id) from orders;

-- Q13: Calculate completed-order revenue.
select * from orders;

select sum(quantity * unit_price * (1-discount / 100)) as total_completed_orders
from orders
where order_status = 'Completed';

--Q14: Calculate the average completed-order value.
select * from orders;

select avg(quantity * unit_price * (1-discount / 100)) as average_completed_orders
from orders
where order_status = 'Completed';

-- Q15: Find the highest and lowest product prices.
select * from orders;

select max(cost_price) as highest_price, min(cost_price) as lowest_price
from orders;

-- Q16: Calculate revenue by product category.
select product_category, sum(quantity * unit_price *(1 - discount / 100)) as total_revenue
from orders
group by product_category;

-- Q17: Count customers by city.
select * from customers;

select city, count(city) as number_of_customers
from customers
group by city;

-- Q18: Calculate quantity sold by product.
select product_name, sum(quantity) as total_sold
from orders
group by product_name;

-- Q19: Find categories generating more than KSh 100,000 in revenue.
select product_category, sum(quantity * unit_price * (1 - discount / 100)) as total_revenue
from orders
group by product_category
having sum(quantity * unit_price * (1 - discount / 100)) > 100000;

-- Q20: Calculate the percentage of cancelled orders.
select * from orders;

select round((count(*) filter (where order_status = 'Cancelled') * 100) / count(*), 2) as total_percentage
from orders;


-- Section C — Joins and customer analytics (Q21–Q28)

-- Q21: Display orders with customer names and cities.
select * from customers;
select * from orders;

select o.order_id, c.customer_name, c.city
from customers c
join orders o
on c.customer_id = o.customer_id;

-- Q22: Calculate total spending by customer.
select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_spending
from orders o
join customers c
on o.customer_id = c.customer_id 
group by c.customer_name, c.customer_id
order by total_spending desc;

-- Q23: Identify customers who have never ordered.
select o.order_id, c.customer_name
from orders o
left join customers c
on o.customer_id = c.customer_id
where order_id is null;

-- Q24: Find the 10 highest-spending customers.
select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_spending
from orders o
join customers c
on o.customer_id = c.customer_id 
group by c.customer_name, c.customer_id
order by total_spending desc
limit 10;

-- Q25: Calculate revenue by customer city.
select * from customers;
select * from orders;

select coalesce(c.city, 'unknown') as city, round(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) as total_revenue
from orders o
right join customers c
on o.customer_id = c.customer_id
group by c.city
order by total_revenue desc;

-- Q26: Identify customers with more than five orders.
select * from customers;
select * from orders;

select c.customer_id, count(o.order_id) as total_orders
from orders o
join customers c
on o.customer_id = c.customer_id 
group by c.customer_id
having count(o.order_id) > 5
order by total_orders desc;

-- Q27: Calculate average customer spending by segment.
select c.customer_segment, round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)) / count(distinct c.customer_id), 2) as average_spending
from customers c
join orders o
on c.customer_id = o.customer_id
group by customer_segment
order by average_spending desc;

-- Q28: Identify the most popular category among VIP customers.
select o.product_category, count(o.order_id) as total_orders
from customers c
join orders o
on c.customer_id = o.customer_id
where c.customer_segment = 'VIP'
group by o.product_category
ORDER BY total_orders desc
limit 1;


-- Section D — Subqueries and CTEs (Q29–Q34)

-- Q29: Find customers spending above the average total spending per purchasing customer.
with customer_spending as (
select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as total_spending
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
)
select customer_id, customer_name, round(total_spending, 2) as total_spending
from customer_spending
where total_spending > (select avg(total_spending) from customer_spending)
order by total_spending desc;

-- Q30: Find products priced above the overall average unit price.
select * from orders;
select * from customers;

-- Overall average
select avg(unit_price) from orders;

with product_priced as (
select product_name, unit_price
from orders o
group by product_name, unit_price
)
select product_name, unit_price
from product_priced
where unit_price > (select avg(unit_price) from product_priced)
order by unit_price desc;

-- Q31: Use a CTE to identify the three highest-revenue months.
with highest_revenue as (
select extract(year from order_date) as order_year, extract(month from order_date) as order_month, sum(quantity * unit_price * (1 - discount / 100.0)) as total_revenue
from orders
group by order_year, order_month 
)
select order_year, order_month, round(total_revenue, 2) as total_revenue
from highest_revenue
order by total_revenue desc
limit 3;

-- Q32: Find customers purchasing from at least three categories.
select * from customers;
select * from orders;

with customer_purchase as (
select c.customer_id, c.customer_name, count(distinct (o.product_category)) as order_categories_count
from orders o
join customers c
on o.customer_id = c.customer_id 
group by c.customer_id, c.customer_name
)
select customer_id, customer_name, order_categories_count
from customer_purchase
where order_categories_count >= 3
order by order_categories_count desc;

-- Q33: Use a CTE to calculate category revenue, cost, profit, and profit margin.
with revenue_generated as (
select product_category, sum(quantity * unit_price * (1 - discount / 100.0)) as total_revenue, sum(quantity * cost_price) as total_cost
from orders
group by product_category
)
select product_category, round(total_revenue, 2) as total_revenue, round(total_cost, 2) as total_cost, 
	round(total_revenue - total_cost, 2) as profit, 
	round((coalesce((total_revenue - total_cost) / nullif(total_revenue, 0), 0) * 100), 2) as proft_margin_percentage -- Profit margin% = profit / NULLIF(revenue, 0) * 100
from revenue_generated
order by proft_margin_percentage desc;

-- Q34: Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.
with customer_orders as (
select c.customer_id, c.customer_name, max(o.order_date) filter (where o.order_status = 'completed') as latest_customer_completed_date,
(select max(order_date) from orders) as absolute_latest_date
from customers c
join orders o 
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
)
select customer_id, customer_name, latest_customer_completed_date, absolute_latest_date,
(absolute_latest_date::date - latest_customer_completed_date::date) as days_inactive
from customer_orders
where latest_customer_completed_date is not null 
  and (absolute_latest_date::date - latest_customer_completed_date::date) > 90
order by days_inactive desc;

-- Q35: Rank customers by spending using RANK()
with customer_spending as (
select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as total_spending
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
)
select customer_id, customer_name, round(total_spending, 2) as total_spending, rank() over (order by total_spending desc) as spending_rank
from customer_spending;

-- Q36: Number each customer's orders by recency using ROW_NUMBER().
select customer_id, order_id, order_date, order_status, 
row_number() over (partition by customer_id order by order_date desc) as order_recency_num
from orders;

-- Q37: Rank products within categories using DENSE_RANK().
select product_category, product_name, unit_price,
dense_rank() over (partition by product_category order by unit_price desc ) as price_rank_in_category
from orders
group by product_category, product_name, unit_price;

-- Q38: Calculate cumulative monthly revenue
select date_trunc('month', order_date)::date as order_month, sum(quantity * unit_price * (1 - discount / 100.0)) as monthly_revenue,
    sum(sum(quantity * unit_price * (1 - discount / 100.0))) over (order by date_trunc('month', order_date)) as cumulative_running_revenue
from orders
group by date_trunc('month', order_date);

-- Q39: Compare monthly revenue using LAG().
select date_trunc('month', order_date)::date as order_month, sum(quantity * unit_price * (1 - discount / 100.0)) as current_revenue,
    lag(sum(quantity * unit_price * (1 - discount / 100.0))) over (order by date_trunc('month', order_date)) as previous_month_revenue
from orders
group by date_trunc('month', order_date);

-- Q40: Calculate month-over-month revenue growth (%).
select date_trunc('month', order_date)::date as order_month, sum(quantity * unit_price * (1 - discount / 100.0)) as current_revenue,
    round(((sum(quantity * unit_price * (1 - discount / 100.0)) - lag(sum(quantity * unit_price * (1 - discount / 100.0))) over (order by date_trunc('month', order_date))) 
        / nullif(lag(sum(quantity * unit_price * (1 - discount / 100.0))) over (order by date_trunc('month', order_date)), 0)) * 100, 
        2) as mom_growth_percentage
from orders
group by date_trunc('month', order_date);

-- Q41: Divide customers into four spending groups using NTILE(4).
select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as total_spending,
    ntile(4) over (order by sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) desc) as spending_quartile
from orders o
join customers c on o.customer_id = c.customer_id
group by c.customer_id, c.customer_name;


-- Q42: Calculate each category's share of total revenue using window functions.
select product_category, sum(quantity * unit_price * (1 - discount / 100.0)) as category_revenue,
    round((sum(quantity * unit_price * (1 - discount / 100.0)) / sum(sum(quantity * unit_price * (1 - discount / 100.0))) over ()) * 100, 
        2) as revenue_share_percentage
from orders
group by product_category;

-- Q43: Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then select from it.
create or replace view monthly_sales_summary as
select to_char(order_date, 'yyyy-mm') as sales_month, count(order_id) as total_orders, 
	round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as total_revenue,
    round(sum(quantity * cost_price), 2) as total_cost,
    round(sum(quantity * unit_price * (1 - discount / 100.0)) - sum(quantity * cost_price), 2) as total_profit
from orders
group by to_char(order_date, 'yyyy-mm'), date_trunc('month', order_date)
order by date_trunc('month', order_date) asc;

select sales_month, total_orders, total_revenue, total_cost, total_profit 
from monthly_sales_summary;

-- Q44: Create a PL/pgSQL function that returns completed-order revenue for a supplied customer ID — show it for one customer and for an ID that does not exist (it must return 0).
create or replace function get_customer_completed_revenue(p_customer_id int)
returns numeric
language plpgsql
as $$
declare
    v_revenue numeric;
begin
    select coalesce(sum(quantity * unit_price * (1 - discount / 100.0)), 0.00)
    into v_revenue
    from orders
    where customer_id = p_customer_id 
      and order_status = 'completed';

    return round(v_revenue, 2);
end;
$$;

select get_customer_completed_revenue(1) as existing_customer_revenue;
select get_customer_completed_revenue(9999) as non_existent_customer_revenue;

-- Q45: Segment customers into High, Medium and Low Value, and explain why you chose your thresholds.
select c.customer_id, c.customer_name, round(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) as total_lifetime_spending,
    case 
        when sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) >= 150000 then 'high value'
        when sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) between 50000 and 149999.99 then 'medium value'
        else 'low value'
    end as customer_value_segment
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
order by total_lifetime_spending desc;

-- Q46: Produce a management report: top five customers, top five products, the most profitable category, and the lowest-revenue month.
select c.customer_name, round(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) as lifetime_spend
from orders o
join customers c on o.customer_id = c.customer_id
group by c.customer_id, c.customer_name
order by lifetime_spend desc
limit 5;

-- Highest-Revenue Products
select product_name, round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as product_revenue
from orders
group by product_name
order by product_revenue desc
limit 5;

-- Most Profitable Product Category
select product_category, round(sum(quantity * unit_price * (1 - discount / 100.0)) - sum(quantity * cost_price), 2) as category_net_profit
from orders
group by product_category
order by category_net_profit desc
limit 1;

-- Lowest-Revenue Calendar Month
select to_char(order_date, 'yyyy-month') as worst_performing_month, round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as monthly_revenue_floor
from orders
group by to_char(order_date, 'yyyy-month'), date_trunc('month', order_date)
order by monthly_revenue_floor asc
limit 1;


-- Stretch

-- 01: Run EXPLAIN ANALYZE on your slowest query, add an index that helps, and show the before and after.
explain analyze
select customer_id, sum(quantity * unit_price * (1 - discount / 100.0))
from orders
group by customer_id;

-- creating an index
create index idx_orders_customer_perf 
on orders (customer_id, quantity, unit_price, discount);

-- 02: Build a monthly cohort-retention table: of customers who first ordered in each month, how many ordered again in later months?
select c.customer_name, to_char(cohorts.first_order_month, 'yyyy-mm') as cohort_month,
    count(distinct case 
	    when date_trunc('month', o.order_date)::date = cohorts.first_order_month 
        then o.customer_id end) as month_0,
    count(distinct case 
        when date_trunc('month', o.order_date)::date = cohorts.first_order_month + interval '1 month' 
        then o.customer_id end) as month_1,
    count(distinct case 
        when date_trunc('month', o.order_date)::date = cohorts.first_order_month + interval '2 months' 
        then o.customer_id end) as month_2,
    count(distinct case 
        when date_trunc('month', o.order_date)::date = cohorts.first_order_month + interval '3 months' 
        then o.customer_id end) as month_3,
    count(distinct case 
        when date_trunc('month', o.order_date)::date = cohorts.first_order_month + interval '4 months' 
        then o.customer_id end) as month_4
from (
    select customer_id, date_trunc('month', min(order_date))::date as first_order_month
    from orders
    group by customer_id
) cohorts
join orders o on cohorts.customer_id = o.customer_id
join customers c on cohorts.customer_id = c.customer_id
group by cohorts.first_order_month, c.customer_name, c.customer_id
order by cohorts.first_order_month asc, c.customer_name asc;


select 'customers' as check_name, count(*)::text as result, '150' as expected from customers
union all select 'orders', count(*)::text, '800' from orders
union all select 'orders with no customer', count(*)::text, '0' from orders o left join customers c using (customer_id) where c.customer_id is null
union all select 'first order date', min(order_date)::text, '2025-01-..' from orders
union all select 'last order date', max(order_date)::text, '2026-09-..' from orders
union all select 'customers with no orders', count(*)::text, 'more than 0' from customers c where not exists (select 1 from orders o where o.customer_id = c.customer_id)
union all select 'customers with 2+ orders', count(*)::text, 'more than 0' from (select customer_id from orders group by customer_id having count(*) >= 2) t
union all select 'customers with 6+ orders', count(*)::text, 'more than 0' from (select customer_id from orders group by customer_id having count(*) > 5) t
union all select 'categories', count(distinct product_category)::text, '5' from orders
union all select 'statuses', string_agg(distinct order_status, ', '), 'cancelled, completed, pending' from orders
union all select 'orders before registration', count(*)::text, '0' from orders o join customers c using (customer_id) where o.order_date < c.registration_date;

select
    round(sum(quantity * unit_price * (1 - discount / 100)), 2) as completed_revenue,
    round(sum(quantity * cost_price), 2) as completed_cost,
    round(sum(quantity * unit_price * (1 - discount / 100)) - sum(quantity * cost_price), 2) as completed_profit
from orders
where order_status = 'Completed';