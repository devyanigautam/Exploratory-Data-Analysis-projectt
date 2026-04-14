/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*segment products into cost ranges and 
  count how many products fall into each segment */

  select cost_range ,product_name,cost,
  count(product_name) over(partition by cost_range ) count_cstrange
  from(
  select product_name,cost
  ,case
             when cost<100  then 'Below 100'
             when  cost Between 100 and 500  then '100-500'  
             when  cost Between 500 and 1000 then '500-1000' 
             when  cost Between 1000 and 1500  then '1000-1500' 
             else 'Above 1500'
   end cost_range 
  from gold.dim_products
  )t
  order by count_cstrange desc


  
  /* 
  Group customers into three segments based on their spending behaviour :
     -VIP : customers with atleast 12 months of history and spending more than $5000.
     -Regular : customers with atleast 12 months of history but spending $5000 or less.
     -NEW : customers with a lifespan less than 12 months
  and find the TOTAL number of customers by each group  
  */
  select *
  from gold.dim_customers
  select *
  from gold.fact_sales


  select segments,count(customer_key) totcustomers
  from(
  select customer_key,
  case 
        when datediff(month,min(order_date),max(order_date)) >=12 and  sum(price) >5000  then 'VIP'
        when datediff(month,min(order_date),max(order_date)) >=12 and sum(price) <=5000  then 'REGULAR'
        when datediff(month,min(order_date),max(order_date)) <12  then 'NEW'
        else 'not defined'
  end segments
  --min(order_date) firstorderdate,  max(order_date) lastorderdate
  ,sum(price) customerspendings
  from gold.fact_sales
  group by customer_key
   --order by customer_key
  )t
  group by segments
  order by totcustomers desc

