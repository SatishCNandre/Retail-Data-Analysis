create database RETAILDATA;
select * from [dbo].[Customer];
select * from [dbo].[prod_cat_info];
select * from [dbo].[Transactions];


--DATA PREPARATION AND UNDERSTANDING
-- 1.TOTAL NUMBER OF ROWS IN EACH OF THE 3 TABLES IN THE DATABASE--

select
(select count(*) from [dbo].[Customer]) as cust_row_count,
(select count(*)  from [dbo].[prod_cat_info]) as prod_cat_info_row_count ,
(select count(*)  from [dbo].[Transactions]) as	transaction_row_count;


--2.TOTAL NUMBER OF TRANSACTIONS THAT HAVE A RETURN.
select count(*) as RETURNTRANSACTION from [dbo].[Transactions] where [total_amt] < 0;



/* 3.As you would have noticed, the dates provided across the 
	datasets are not in a correct format. As first steps, pls 
	convert the date variables into valid date formats before
	proceeding ahead*/

select format([DOB],'dd-MM-yyyy') as formated_date from [dbo].[Customer];
select format([tran_date],'dd-MM-yyyy') as formated_date from [dbo].[Transactions];


/* 4. What is the time range of the transaction data available for analysis? 
	Show the output in number of days, months and years simultaneously
	in different columns.*/
-- Calculate the time range in days
select 
datediff(day,min([tran_date]),max([tran_date])) as Num_Days,
datediff(month,min([tran_date]),max([tran_date])) as Num_Months,
datediff(year,min([tran_date]),max([tran_date])) as Num_Years
from [dbo].[Transactions];


/* 5.Which product category does the sub-category �DIY� belong to?*/

select [prod_cat],[prod_subcat]
from [dbo].[prod_cat_info]
where [prod_subcat] ='DIY';



--DATA ANALYSIS--

/* 1.Which channel is most frequently used for transactions? */

select top 1 [Store_type],count(*) as COUNT_OF_TRANSACTIONS
from [dbo].[Transactions]
group by [Store_type]
order by COUNT_OF_TRANSACTIONS desc;



/* 2.What is the count of Male and Female customers in the database? */

select [Gender],count(*) as COUNT_OF_CUSTOMERS 
from [dbo].[Customer]
where [Gender] in ('M','F')
group by [Gender];


/* 3.From which city do we have the maximum number of customers and how many? */
select top 1 [city_code],count(*) as NUMBER_OF_CITIES
from [dbo].[Customer]
group by [city_code]
order by NUMBER_OF_CITIES desc;


/* 4.How many sub-categories are there under the Books category? */

select [prod_cat],count(*) as NO_OF_SUBCATEGORIES
from [dbo].[prod_cat_info]
where [prod_cat]='Books'
group by [prod_cat];



/* 5.What is the maximum quantity of products ever ordered? */
select top 1 [Qty] 
from [dbo].[Transactions]
order by [Qty] desc;



/* 6.What is the net total revenue generated in categories Electronics and Books? */

select
[prod_cat],
sum([total_amt]) as REVENUE
from 
[dbo].[Transactions] as T
inner join
[dbo].[prod_cat_info] as P on T.[prod_cat_code]=P.[prod_cat_code] and T.prod_subcat_code=P.prod_sub_cat_code
where P.[prod_cat] IN ('Electronics','Books')
group by [prod_cat];


/* 7.How many customers have >10 transactions with us, excluding returns? */



 select count([customer_Id]) as cust_count
from [dbo].[Customer] where [customer_Id] in
( select [customer_Id] from [dbo].[Transactions] t
inner join [dbo].[Customer] c on t.cust_id=c.customer_Id
where [total_amt] !<0
group by [customer_Id]
having count([transaction_id]) > 10);


 
/* 8.What is the combined revenue earned from the �Electronics� & �Clothing�
	categories, from �Flagship stores�?*/
 
 select
 sum([total_amt]) as total_amount from [dbo].[Transactions] as T
 inner join 
[dbo].[prod_cat_info] as P on T.[prod_cat_code]=P.[prod_cat_code] and T.[prod_subcat_code]=P.[prod_sub_cat_code]
where
[prod_cat] in ('Clothing','Electronics') and [Store_type]='Flagship store'






/* 9.What is the total revenue generated from �Male� customers 
	in �Electronics� category? Output should display total revenue by 
	prod sub-cat.*/
 
select
[Gender],
[prod_cat],
[prod_subcat],
sum([total_amt]) as TOTAL_REVENUE
from
[dbo].[Customer] as C
inner join [dbo].[Transactions] as T on C.customer_Id = T.cust_id
inner join [dbo].[prod_cat_info] as P on T.[prod_cat_code]=P.prod_cat_code
group by
[Gender],
[prod_cat],
[prod_subcat]
having
C.Gender='M' AND P.prod_cat='Electronics';




/* 10.What is percentage of sales and returns by product sub category; 
    display only top 5 sub categories in terms of sales? */


select top 5
[prod_subcat],
(sum([total_amt])/(select sum([total_amt]) from [dbo].[Transactions])) * 100 as sales_percentage,
(count(case when [total_amt]<0 then [total_amt] else null end)/sum([total_amt])) * 100 as return_percentage
from [dbo].[Transactions] t
inner join
[dbo].[prod_cat_info]as p on t.prod_cat_code=p.prod_cat_code  and  t.prod_subcat_code =p.prod_sub_cat_code
group by
[prod_subcat]
order by
sum([total_amt]) desc;




/* 11.For all customers aged between 25 to 35 years find what is the 
	net total revenue generated by these consumers in last 30 days of transactions
	from max transaction date available in the data? */
select
[cust_id],
sum([total_amt]) as revenue from [dbo].[Transactions]
where
[cust_id] in 
(select [customer_Id] from [dbo].[Customer] where datediff(year,convert(date,[DOB],103),getdate()) between 25 and 35)
and convert (date,[tran_date],103) between dateadd(day,-30,(select max(convert(date,[tran_date],103))from [dbo].[Transactions])) and (select max(convert(date,[tran_date],103)) from [dbo].[Transactions])
group by [cust_id];



/* 12.Which product category has seen the max value of returns in the last 3 
	months of transactions?*/

select top 1 [prod_cat], sum([total_amt]) as Total_amount from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P on T.[prod_cat_code]=P.[prod_cat_code] and T.[prod_subcat_code]=P.[prod_sub_cat_code]
where [total_amt] < 0 and
convert(date,[tran_date],103) between dateadd(month,-3,(select max(convert(date,[tran_date],103)) from [dbo].[Transactions])) 
      and (select max(convert(date,[tran_date],103)) from [dbo].[Transactions])
group by [prod_cat]
order by Total_amount desc



/* 13.Which store-type sells the maximum products; by value of sales amount and
	by quantity sold? */

select top 1[Store_type], 
sum([total_amt]) as total_sales,
sum([Qty]) as total_quantity
from [dbo].[Transactions]
group by [Store_type]
order by total_quantity desc;



/* 14.	What are the categories for which average revenue is above the overall average. */

 select [prod_cat],avg([total_amt]) as average_revenue
from [dbo].[Transactions] as T
inner join [dbo].[prod_cat_info] as P on T.[prod_cat_code]=P.[prod_cat_code] and T.[prod_cat_code]=P.[prod_cat_code]
group by [prod_cat]
having avg([total_amt])> (select avg([total_amt]) from [dbo].[Transactions])



/* 15.Find the average and total revenue by each subcategory for the categories 
	which are among top 5 categories in terms of quantity sold. */

select top 5 [prod_cat],[prod_subcat], 
avg([total_amt]) as average_revenue, 
sum([total_amt]) as revenue from [dbo].[Transactions] as T
inner join [dbo].[prod_cat_info] as P on T.[prod_cat_code]=P.[prod_cat_code] and T.[prod_subcat_code]=P.[prod_sub_cat_code]
where [prod_cat] in
( select top 5 [prod_cat] from [dbo].[Transactions] as T
inner join [dbo].[prod_cat_info] as P on T.[prod_cat_code]=P.[prod_cat_code] and T.[prod_subcat_code]=P.[prod_sub_cat_code]
group by [prod_cat]
order by sum([Qty]) desc)
group by 
[prod_cat],[prod_subcat]
 

 ----------------