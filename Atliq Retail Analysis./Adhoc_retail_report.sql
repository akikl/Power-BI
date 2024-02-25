-- 1. Provide a list of products with a base price greater than 500 and that are featured in promo type BOGOF("Buy One Get One Free) 
SELECT DISTINCT(p.product_name),f.base_price,f.promo_type
FROM fact_events f
JOIN
dim_products p
ON p.product_code=f.product_code
WHERE f.base_price>500
AND f.promo_type LIKE 'BOGOF';
--------------------------------------------------------------------------------------------------------------------------------------
/* 2. Generate a report that provides an overview of the number of stores in each city.
The results will be sorted in descending order of store counts.*/
SELECT city,count(store_id) AS 'Store_count'
FROM dim_stores
GROUP BY CITY
ORDER BY Store_count DESC;
--------------------------------------------------------------------------------------------------------------------------------------
-- 3. Generate a report that displays each campaign along with total revenue generated before and after campaign?
SELECT c.campaign_name,
SUM((f.base_price) * f.`quantity_sold(before_promo)`)/1000000 AS 'Total_revenue(before_promo)',
SUM((f.base_price) * f.`quantity_sold(after_promo)`)/1000000  AS 'Total_revenue(after_promo)'
FROM dim_campaigns c
JOIN fact_events f
ON c.campaign_id = f.campaign_id
GROUP BY c.campaign_name;
--------------------------------------------------------------------------------------------------------------------------------------
/*4. Produce a report that calculates the incremental sold quantity (ISU%) for each category during the diwali campaign.
Provide rankings for the categories based on ISU % */

WITH QTY AS(
SELECT p.category, 
(SUM(f.`quantity_sold(after_promo)`) - SUM(f.`quantity_sold(before_promo)`))/(SUM(f.`quantity_sold(before_promo)`))*100 AS 'ISU%'
FROM fact_events f
JOIN dim_products p
ON p.product_code=f.product_code
JOIN dim_campaigns c ON
c.campaign_id=f.campaign_id
WHERE c.campaign_name='Diwali'
GROUP BY 
p.category)
SELECT *,
RANK() OVER(ORDER BY `ISU%` DESC) AS 'rank_order'
FROM QTY;
--------------------------------------------------------------------------------------------------------------------------------------
WITH Revenue AS (
SELECT p.product_name,p.category,
(SUM((f.base_price) * f.`quantity_sold(after_promo)`) -
SUM((f.base_price) * f.`quantity_sold(before_promo)`))/(SUM((f.base_price) * f.`quantity_sold(before_promo)`)) *100
AS 'IRU%'
FROM dim_campaigns c
JOIN fact_events f
ON c.campaign_id = f.campaign_id
JOIN dim_products p
ON p.product_code=f.product_code
GROUP BY p.product_name,p.category) ,
HIGH AS(
SELECT *,
RANK() OVER(ORDER BY `IRU%` DESC) AS rank_order
FROM Revenue)
SELECT product_name,category,`IRU%` FROM HIGH 
WHERE rank_order<=5;
--------------------------------------------------------------------------------------------------------------------------------------