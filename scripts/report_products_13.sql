/*
==========================================================================================
                                   
                                   PRODUCT REPORT

==========================================================================================
Purpose:
  -  This report consolidates key customer metrics and behaviours

HIGHLIGHTS:

 1. Gathers essential fields such as 
      * product name
      * category
      * subcategory
      * cost
 2. Segments products by revenue to identify ( High-Performers ,Mid-Range ,Low-Performers).
 3. Aggregates product - level metrics:
          - total orders
          - total sales
          - total quantity sold
          - total customers (unique)
          - lifespan (in months)
 4. Calculates valuable KPIs:
    - recency (months since last sale)
    - average order revenue (AOR)
    - average monthly revenue
==========================================================================================
*/

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

Create VIEW gold.report_products as
  with base_query as(
  /*-----------------------------------------------------------------
    1) Base Query : Retrieves core columns from tables  
  -------------------------------------------------------------------*/
  select
  fs.order_number,dp.product_key,fs.customer_key,fs.order_date,fs.sales_amount,
  fs.quantity,dp.product_name,dp.category,dp.subcategory,dp.cost
  from gold.fact_sales fs
  left join gold.dim_products dp
  on fs.product_key=dp.product_key
  where fs.order_date is not null)
  
  ,customer_aggregation as(
  /*-----------------------------------------------------------------
   3) Customer Aggregations : Summarizes key metrics at the product level
  -------------------------------------------------------------------*/
  select product_key,product_name,category,subcategory,cost,
  count(distinct order_number) totalorders,
  count(distinct sales_amount) totalsales,
  sum(sales_amount) total_sales,
  sum(quantity) total_quantity,
  count(distinct customer_key) totcust,
  max(order_date) last_order_date,
  datediff(month,min(order_date),max(order_date)) lifespan,
  round(avg(cast(sales_amount as float)/nullif(quantity,0)),1) avg_selling_price
  from base_query
  group by 
    product_key,product_name,category,subcategory,cost
)
select
 product_key,product_name,category,subcategory,cost,last_order_date,
 datediff(month,last_order_date,GETDATE()) recency_in_months
/*-----------------------------------------------------------------
   2) Segments products by revenue ( High-Performers ,Mid-Range ,Low-Performers ).
  -------------------------------------------------------------------*/
 ,case
     when total_sales >50000 then   'High-Performer'
     when total_sales >10000 then   'Mid-Range'
     else  'Low-Performer'
  end product_segment
  ,lifespan,totalorders,total_sales,total_quantity,totcust,avg_selling_price
 -- Compute average order revenue(AOR)  [average order value=total sales/total nr.of orders]
  ,case 
     when totalorders=0 then 0
     else (total_sales/totalorders)
  end avg_order_revenue
  -- Compute average monthly revenue(AMR)  [average monthly spend = Total Sales/Nr. of months ]
  ,case 
      when lifespan=0 then total_sales
      else total_sales/lifespan
  end avg_monthly_revenue  
 from customer_aggregation 

 -- select * from gold.report_products
