
-- Retrive the total orders placed
SELECT 
    COUNT(order_id)
FROM
    orders;

-- calculate total revenue generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- Identify the highest priced pizza

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    ORDER BY pizzas.price DESC LIMIT 1;
    
--     Identify the most common pizza size ordered

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities

SELECT 
    pizzas.pizza_id, COUNT(order_details.quantity) as order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id GROUP BY pizzas.pizza_id
    ORDER BY order_count DESC

LIMIT 5;


-- intermediate
-- join the necessary tables to find the total quantity of each pizza  Category ordered
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;
-- determine the distribution of order by hour of the day
select hour(time),count(order_id) from orders group by hour(time);


-- Join relevant tables to find the category wise distribution of pizzas
select category, count(name) from pizza_types group by category;


-- Group the orders by date and calculate the average no. of pizzas ordered per day
SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue
LIMIT 3;

-- Advanced

-- Calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pizza_types.category,
    round(SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id)*100,2) AS revenue_contri
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_contri DESC;


-- Analyse the cumulative revenue generated over time
select orders.date ,
sum(revenue) over(order by orders.date) as cum_revenue 
from 
(select orders.date ,sum(order_details.quantity* pizzas.price) as revenue
from order_details join pizzas 
on order_details.pizza_id=pizzas.pizza_id
join orders 
on orders.order_id=order_details.order_id
group by orders.date)as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, category,revenue from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.category, pizza_types.name,sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as B where rn<=3;
