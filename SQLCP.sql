#Data Wrangling:

/* Create database named project*/
create database project;

/* use database or double click on databse name to use it available under schemas*/
/* Drop table amazon if exists for creation of new amazon table*/
drop table amazon;

/*create table amazon with column names and data types*/
create table amazon(
Invoice_ID VARCHAR(30),	
Branch	VARCHAR(5),
City VARCHAR(30),
Customer_type	VARCHAR(30),
Gender	VARCHAR(10),
Product_line VARCHAR(100),	
Unit_price DECIMAL(10, 2),	
Quantity	INT,
VAT FLOAT,
Total	DECIMAL(10, 2),
`Date`	date,
`Time` time,
payment_method varchar(50),
cogs	DECIMAL(10, 2),
gross_margin_percentage	FLOAT,
gross_income DECIMAL(10, 2),	
Rating FLOAT);

/*import data from datset provided(Amazon) */
/*count of rows in table*/
SELECT count(*) FROM amazon;

/*count of columns in dataset*/
SELECT count(*) as no_of_cols FROM INFORMATION_SCHEMA.columns WHERE table_name = 'amazon';

/*Schema of amazon*/
select column_name,data_type from information_schema.columns
where table_schema = 'project' AND table_name = 'amazon'; 

/*Finding rows with NULL values*/
select * from amazon where Invoice_ID is null or Branch is null or City is null or 
Customer_type is null or Gender is null or Product_line is null or Unit_price is null or Quantity is null
or VAT is null or Total is null or `Date` is null or `Time` is null or payment_method is null or 
cogs is null or gross_margin_percentage is null or gross_income is null or Rating is null;

/*Finding columns with NULL values*/
select  sum(Invoice_ID is null) ,
 sum(Branch is null),sum(City is null ),
 sum(Customer_type is null) ,
 sum(Gender is null ),
 count(Product_line is null ), count(Unit_price) is null ,
 count(Quantity is null),
 count(VAT is null) ,count( Total is null) ,
 count(`Date` is null ),count(`Time` is null ),
 count(payment_method is null) ,count(cogs is null) ,
 count(gross_margin_percentage is null) ,count( gross_income is null ),count( Rating is null) from amazon;

# Feature Engineering: 
/*Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. 
This will help answer the question on which part of the day most sales are made.*/
/*create column timeofday*/
alter table amazon
add column timeofday varchar(30); 
/*computing values of timeofday as Morning, Afternoon and Evening*/
UPDATE amazon
SET timeofday = 
  CASE 
    WHEN HOUR(`time`) BETWEEN 5 AND 11 THEN 'Morning'
    WHEN HOUR(`time`) BETWEEN 12 AND 16 THEN 'Afternoon'
    ELSE 'Evening'
  END;
  /*Viewing values of timeofday*/
  select time,timeofday from amazon;
  /*part of the day most sales are made.*/
  select timeofday, count(*) as sales from amazon group by timeofday order by count(*) desc;

  
  /*Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
  This will help answer the question on which week of the day each branch is busiest.*/
  /*create a column dayname*/
  alter table amazon
  add column `dayname` varchar(10);
/*computing values as Monday,Tueday,..Saturday*/
UPDATE amazon
SET `dayname`=dayname(`date`);
/*Viewing values of dayname*/
select `date`,`dayname` from amazon;
/*which week of the day each branch is busiest.*/
select distinct Branch,`dayname`,count(*) from amazon group by branch,`dayname` order by count(*) desc;

/* Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). 
Help determine which month of the year has the most sales and profit.*/
/*create a new column monthname*/
alter table amazon
add column monthname varchar(20);
/*computing values of monthname*/
update amazon
set monthname=monthname(`date`);
/*viewing values of monthname*/
select `date`,monthname from amazon;
/*month of the year has the most sales and profit*/
select year(`date`) as `year`,monthname,sum(total) as total_sales,sum(gross_income) as total_profit from amazon
group by `year`,monthname 
order by total_sales desc;

# Exploratory Data Analysis (EDA): 

/*What is the count of distinct cities in the dataset*/
select count(distinct city) as city_count from amazon;

/*For each branch, what is the corresponding city*/
select distinct branch,city from amazon;

/*What is the count of distinct product lines in the dataset*/
select count(distinct product_line) as product_line_count from amazon;

/*Which payment method occurs most frequently*/
select payment_method, count(payment_method) as payment_frequency from amazon group by payment_method order by count(payment_method) desc ;

/*Which product line has the highest sales*/
select product_line,sum(total) as sales_amnt from amazon group by product_line order by sales_amnt desc limit 1;

/*How much revenue is generated each month*/
select monthname,sum(total) as revenue from amazon group by monthname ;

/*In which month did the cost of goods sold reach its peak*/
select monthname,sum(cogs) as total_cogs from amazon
group by monthname order by sum(cogs) desc limit 1;

/*Which product line generated the highest revenue*/
select product_line from amazon
group by Product_line order by sum(total) desc limit 1;

/*In which city was the highest revenue recorded*/
select city from amazon group by city order by sum(total) desc limit 1;

/*Which product line incurred the highest Value Added Tax*/
select product_line from amazon group by product_line order by sum(vat) desc limit 1;

/*For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."*/
select distinct a.product_line,case
when sum(total)>(select avg(total) as avg_sale from amazon b where a.Product_line=b.Product_line group by Product_line) then "Good"
else "Bad"
end as product_line_performance from amazon a 
group by Product_line;

/*Identify the branch that exceeded the average number of products sold.*/
select 
    branch,
    sum(quantity) as total_products_sold from amazon
group by branch
having SUM(quantity) > (
    select avg(total_qty) 
    from (
        select sum(quantity) as total_qty
        from amazon
        group by branch
    ) as branch_totals
);

/*Which product line is most frequently associated with each gender*/
select gender,product_line,count(product_line) as product_line_freq from amazon group by gender,Product_line order by product_line_freq desc limit 1;

/*Calculate the average rating for each product line*/
select product_line,avg(rating) as avg_rating from amazon group by Product_line order by avg_rating desc;

/*Count the sales occurrences for each time of day on every weekday.*/
select `dayname`,timeofday,count(Invoice_ID) as sale_occurance from amazon group by `dayname`,timeofday order by sale_occurance desc;

/*Identify the customer type contributing the highest revenue.*/
select customer_type from amazon group by Customer_type order by sum(total) desc limit 1;

/*Determine the city with the highest VAT percentage.*/
select city from amazon group by city order by sum(vat) desc limit 1;

/*Identify the customer type with the highest VAT payments.*/
select customer_type from amazon group by Customer_type order by sum(vat) desc limit 1;

/*What is the count of distinct customer types in the dataset*/
select customer_type,count(Customer_type) as cust_type_count from amazon group by customer_type;

/*What is the count of distinct payment methods in the dataset*/
select payment_method,count( payment_method)  as payment_method_count from amazon group by payment_method;

/*Which customer type occurs most frequently*/
select customer_type from amazon group by Customer_type order by count(Invoice_ID) desc limit 1;

/*Identify the customer type with the highest purchase frequency*/
select customer_type from amazon group by Customer_type order by count(*) desc limit 1;

/*Determine the predominant gender among customers.*/
select gender from amazon group by gender order by count(*) desc limit 1;

/*Examine the distribution of genders within each branch.*/
select branch,gender,count(gender) from amazon group by branch,gender order by count(gender) desc;

/*Identify the time of day when customers provide the most ratings.*/
select timeofday from amazon group by timeofday order by sum(rating) desc limit 1;

/*Determine the time of day with the highest customer ratings for each branch.*/
select branch,timeofday from amazon group by branch,timeofday order by sum(rating) desc limit 1;

/*Identify the day of the week with the highest average ratings.*/
select dayname from amazon group by dayname order by avg(rating) desc limit 1;

/*Determine the day of the week with the highest average ratings for each branch.*/
select branch,dayname from amazon group by branch,dayname order by avg(rating) desc limit 1;

#Product Analysis:

/*Sales and Performance by Product Line.*/
select product_line,count(*) as number_of_orders,sum(total) as sales_amount,avg(rating) as avg_rating from amazon
group by Product_line order by avg_rating desc;

/*Profitability of each month by Product Line:*/
select product_line,monthname,sum(gross_income) as profitability from amazon group by product_line,monthname order by profitability desc; 

#Sales Analysis:

/* Daily Sales Volume*/
select `date`,sum(total) as revenue from amazon group by `date` order by `date`desc;

/* sales volume of each day of week*/
select dayname as day,sum(total) as sales_volume from amazon
group by dayname
order by sales_volume desc;

/*monthly sales volume*/
select monthname,sum(total) as sales_volume from amazon
group by monthname
order by sales_volume desc;

/*running total of revenue per month*/
select  distinct `date`,sum(total)over(partition by month(`date`) order by `date` desc) as montly_revenue from amazon ;

/*compare each branch profit by monthly average*/
select distinct branch,monthname,sum(gross_income) as profit,avg(sum(gross_income))over(partition by monthname) as avg_mnthly_profit from amazon group by branch,monthname;

/*compare  each transaction with daily revenue*/
select invoice_id,`date`,total,
sum(total)over(partition by `date` order by `time` rows between unbounded preceding and current row ) as day_running_revenue,
sum(total)over(partition by `date`) as day_revenue from amazon ;

/*percentage of monthly sales share for each branch*/
select branch,monthname,sum(total) as branch_total,
100*sum(total)/sum(sum(total))over( partition by monthname) as percentage_share from amazon
group by branch,monthname order by percentage_share desc;

#Customer Analysis:

/*customer type purchases */
select customer_type,count(*) as total_purchases,sum(total) as total_revenue,round(avg(total),2) as avg_order_val,sum(gross_income) as total_profit
from amazon group by customer_type order by total_revenue desc;

/*gender based spending behaviour*/
select gender,count(*) as num_sales,sum(total) as revenue from amazon group by gender;

/*gender wise member_type distibution*/
select gender,Customer_type,count(*) as orders from amazon group by gender,Customer_type

/*product prefernce by customer*/
select product_line,customer_type,count(*) as num_orders,sum(total) as revenue from amazon
group by Customer_type,Product_line order by revenue desc;

/*Ranking customer type with corresponding city with respect to revenue*/
select customer_type,city,payment_method,sum(total) as revenue,rank()over( order by sum(total) desc) as rank_city_ct from amazon group by city,customer_type,payment_method;

#SUMMARY:
/*Data Overview:
1000 Rows,20 Columns.
2 customer_types(Member,Normal).
6 product_lines.
3 branches located in 3 cities.
2 genders, 3 payment methods, VAT, revenue, cogs and ratings.
No missing values were detected—ensuring a clean dataset for analysis.

Product Insights:
Most sold product line: Food and Beverages ( based on your top sales(revenue) result).
Highest VAT,Highest average rating are also incurred by the top-selling product line.
Fashion accessories are more ordered by female. 
Sports and travel has more profit in January. 
Product lines are labeled "Good" or "Bad" based on sales performance compared to the average.And found all product lines are good. 

Sales Insights:
Peak sales month by revenue and COGS is JANUARY.
peak rating time of day is afternoon of branch A.
Peak average rating time of day: After noon of branch B.
More number of orders are at wednesday afternoon. 
Highest revenue on Saturday. 
Highest rating on Monday. 
2019-03-30 is found as highest revenue production day. 
Payment_mode distribution is as follows: Ewallet-345, Cash-344, Credit_card-311. 
A branch is at Yangon city which exceeded Average number of product sold. 
B branch is at Mandalay city. 
C branch is at Naypyitaw city has highest revenue in Cash payment_mode. 
 
 Customer Insights:
 Female has more number of orders. 
 Branches A,B recevied more oreders from Male.
 Branch C has receivied more orders from Female. 
 We have 2 customer_types:
    1.Member(Membership) where gender distribution is 261 Female and 240 Male 501 in Total.
    2.Normal(Non-Membership) where gender distribution is 240 Female and 259 Male 499 in Total. 
 Member customer_type has more revenue,VAT,more number of orders. */
 





