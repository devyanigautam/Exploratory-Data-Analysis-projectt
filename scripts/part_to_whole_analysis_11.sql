/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Which Categories contribute the most to overall sales?

select dp.category,sum(fs.sales_amount) totsales,
concat(round((cast(sum(fs.sales_amount)as float)/sum(sum(fs.sales_amount))over())*100,2),'%' ) percentage_of_total
from gold.fact_sales fs
left join gold.dim_products dp
on fs.product_key=dp.product_key
group by dp.category
order by totsales desc
