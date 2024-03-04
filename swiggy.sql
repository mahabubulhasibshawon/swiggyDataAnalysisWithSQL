--Swiggy Case Study-

--1. Find customers who have never ordered

SELECT name
FROM `users` 
WHERE user_id not in (SELECT user_id FROM orders)

--2. Average Price/dish

SELECT f.f_name, AVG(price) as 'AVG PRICE'
FROM menu m
join food f
ON f.f_id = m.f_id
GROUP BY f.f_id

--3. Find the top restaurant in terms of the number of orders for a given month

select r.r_name, COUNT(*) as 'MONTH'
from orders o
JOIN resturants r
ON o.r_id = r.r_id
WHERE MONTHNAME(date) LIKE 'june'
GROUP BY o.r_id
ORDER BY COUNT(*) DESC LIMIT 1

--4. restaurants with monthly sales greater than x for 

SELECT r.r_name, SUM(amount) as 'revenue'
from orders o
JOIN resturants r
on o.r_id = r.r_id
WHERE MONTHNAME(date) LIKE 'june'
GROUP BY o.r_id
HAVING revenue>500
order by revenue DESC

--5. Show all orders with order details for a particular customer in a particular date range

SELECT  o.order_id, r.r_name, f.f_name
FROM orders o
JOIN resturants r
ON r.r_id = o.r_id
JOIN order_details od
ON od.order_id = o.order_id
JOIN food f
ON f.f_id = od.f_id
WHERE user_id = (SELECT user_id FROM users WHERE name LIKE 'Ankit') AND (date BETWEEN '2022-06-10' AND '2022-07-10')


--6. Find restaurants with max repeated customers 

SELECT r.r_name, COUNT(*) as 'Loyal_Customers'
FROM(
	SELECT r_id, user_id, COUNT(*) as 'visit'
    FROM orders
    GROUP BY r_id, user_id
    HAVING visit>1
)t
JOIN resturants r
ON r.r_id = r.r_id
GROUP BY t.r_id
ORDER BY Loyal_Customers DESC LIMIT 1

--7. Month over month revenue growth of swiggy

SELECT month, ((revenue-prev)/prev)*100 FROM(
    WITH sales AS
(
	SELECT MONTHNAME(date) AS 'month',SUM(amount) AS 'revenue'
	FROM orders
	GROUP BY month
    ORDER BY MONTH(date)
)
SELECT month, revenue, LAG(revenue,1) AS 'prev' OVER(order BY revenue) from sales
)t

--8. Customer - favorite food

WITH temp AS
(
    SELECT o.user_id,od.f_id,COUNT(*) AS 'frequency'
    FROM orders o
    JOIN order_details od
    ON o.order_id = od.order_id
    GROUP BY o.user_id, od.f_id
)
SELECT u.name, f.f_name,frequency
FROM temp t1
JOIN users u
ON u.user_id = t1.user_id
JOIN food f
ON f.f_id = t1.f_id
WHERE t1.frequency=(
    SELECT MAX(frequency)
    FROM temp t2
    WHERE t2.user_id = t1.user_id
)

