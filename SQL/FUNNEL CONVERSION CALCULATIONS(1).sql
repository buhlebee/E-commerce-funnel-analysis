--FUNNEL CALCULATIONS
--i made two tables one where i included items removed from cart and also other detailed calculations...
select * from funnel_stages_detailed;
--for detailed calculations

--for usual funnel calculations
select*from funnel_stages;

--COUNT THE TOTAL AMOUNT OF USERS AT EACH STAGE--
select
sum(viewed) as total_views,--SUM() COUNTS THE ADDS/COUNTS EVERYTHING
sum(carted) as total_carted,--ITS GOING TO COUNT CARTED EVEN IF THE USER CARTED MULTIPLE TIMES
sum(purchased) as total_purchases
from funnel_stages;
--CONVERSION RATE CALCULATIONS
select
sum(viewed) as total_views,
sum(carted) as total_carted,
sum(purchased) as total_purchases,
--CALCULATIONS
--1st one is the view to cart ratio
sum( carted)*100/ NULLIF(sum(viewed),0) as view_to_cart_percentage,--- THE NULLIF WILL HELP AVOID ERRORS IN THIS QUERY.PROTECTS THE CALCULATION
--cart to purchase ratio
sum( purchased)*100/ NULLIF(sum(carted),0) as cart_to_purchase_percentage,---INSTEAD OF AN ERROR IT WILL RETURN THE NULL VALUE(0).
--view to purchase ratio
sum( purchased)*100/ NULLIF(sum(viewed),0) as view_to_purchase_percantage
from funnel_stages;

---MONTHLY FUNNEL VIEW, HOW FREQUENT CUSTOMERS VISITED,CARTED AND PURCHASED ,THE FIRST ALONE WONT WORK IT WILL RETURN REDUNDANT VALUES
---SO IM DOING IT IN TWO STEPS TO ELIMINATE REDUNDANCY,THOUGH THERE IS A LONGER METHOD
---ROW PER CUSTOMER PER MONTH/VISIT
with monthly_funnel as (
   select
       event_month,
       user_id,
       MAX(viewed) AS viewed,--- USED MAX AS THE MAX VALUE SHOULD BE ONE , IT WONT TAKE THE ZEROS TO ACCOUNT
       MAX(carted) AS carted,---I DID IT ON THE FUNNEL STAGES SCRIPT BUT NOTHINGS WRONG WITH MAKING SURE
       MAX(purchased) AS purchased
    from funnel_stages_detailed
    group by event_month, user_id
)
-- STEP 2: TOTAL PER MONTH
select
    event_month,
    sum(viewed) AS total_views,
    sum(carted) AS total_carted,
    sum(purchased) AS total_purchases,
    --CALCULATIONS
--1st one is the view to cart ratio
    sum( carted)*100/ NULLIF(sum(viewed),0) as view_to_cart_percentage,
--cart to purchase ratio
    sum( purchased)*100/ NULLIF(sum(carted),0) as cart_to_purchase_percentage,
--view to purchase ratio
   sum( purchased)*100/ NULLIF(sum(viewed),0) as view_to_purchase_percantage
from monthly_funnel
group by event_month
order by event_month;

--SHOULD WORK


----PRODUCT AND CATEGORY TOTALS
--THE FIRST ONE IS FOR THE PRODUCTS TO TRACK HOW MANY WERE VIEWED,CARTED AND PURCHASED
with product_funnel as (
  select
     product_id,
     user_id,
     max(viewed) as viewed,
     max(carted) as carted,
     max(purchased) as purchased
    from funnel_stages_detailed
    group by product_id, user_id
)
select
product_id,
sum(viewed) as total_views,
sum(carted) as total_carted,
sum(purchased) as total_purchases
from product_funnel
group by product_id;

--THE SECOND ONE IS FOR CATEGORIES
with category_funnel as (
  select
     category_id,
     user_id,
     max(viewed) as viewed,
     max(carted) as carted,
     max(purchased) as purchased
    from funnel_stages_detailed
    group by category_id, user_id
 )
select
category_id,
sum(viewed) as total_views,
sum(carted) as total_carted,
sum(purchased) as total_purchases
from category_funnel
group by category_id;

--- NOW FOR THE LAST PART OF THE FUNNEL IM GOING TO CALCULATE THE DROP-OFF VALUE AND DROP-OFF PERCANTAGE
-- STARTING WITH THE DROP OFF VALUE, WHERE IT SHOWS HOW MANY CUSTOMERS PROGRESSED TO THE NEXT PHASE
select
sum(viewed) as total_views,
sum(carted) as total_carted,
sum(purchased) as total_purchases,
sum(viewed)-sum(carted) as view_carted_dropoff,
sum(carted)-sum(purchased) as cart_purchase_dropoff

from funnel_stages;
--NOW WITH THE DROP OFF PERCANTAGE WHERE IT SHOWS THE PERCENTAGE OF CUSTOMERS THAT PROGRESSED FROM ONE STAGE TO ANOTHER
select
sum(viewed) as total_views,
sum(carted) as total_carted,
sum(purchased) as total_purchases,
(sum(viewed)-sum(carted)) *100/ NULLIF(sum(viewed),0)as view_carted_dropoff_percent,
(sum(carted)-sum(purchased)) *100 / NULLIF(sum(carted),0) as cart_purchase_dropoff_percent,
 
from funnel_stages;
--- 75% of the customers dont put stuff in their carts, and from the people who do put stuff in their cart 72% of them dont check out or purchase the item
---
---NOW THAT EVERYTHING LOOKS CLEAN IM GOING TO CREATE TABLES FOR THE FOLLOWING FUNNEL CONVERSIONS SO I CAN USE THEM ON POWERBI
--- PRETTY MUCH JUST COPIED THE QUERIES FROM ABOVE AND ANDED CREATE TABLE FUNCTION TO CREATE THE TABLES
create table bi_monthly_funnel as
with monthly_funnel as (
   select
       event_month,
       user_id,
       MAX(viewed) AS viewed,
       MAX(carted) AS carted,
       MAX(purchased) AS purchased
    from funnel_stages_detailed
    group by event_month, user_id
)
select
    event_month,
    sum(viewed) AS total_views,
    sum(carted) AS total_carted,
    sum(purchased) AS total_purchases,
    sum( carted)*100/ NULLIF(sum(viewed),0) as view_to_cart_percentage,
    sum( purchased)*100/ NULLIF(sum(carted),0) as cart_to_purchase_percentage,
   sum( purchased)*100/ NULLIF(sum(viewed),0) as view_to_purchase_percantage
from monthly_funnel
group by event_month
order by event_month;


--I DIDNT CHANGE ANYTHING MUCH HERE JUST ADDED 'ORDER BY DESC' FOR POWERBI SO THE TABLE WILL PRODUCTS WITH THE MOST VISITS ON TOP 
create table bi_product_funnel as
with product_funnel as (
  select
     product_id,
     category_id,
     user_id,
     max(viewed) as viewed,
     max(carted) as carted,
     max(purchased) as purchased
    from funnel_stages_detailed
    group by product_id,category_id, user_id
)
select
product_id,
category_id,
sum(viewed) as total_views,
sum(carted) as total_carted,
sum(purchased) as total_purchases
from product_funnel
group by product_id,category_id
order by total_views desc;


---SAME THING I DID ON BI PRODUCT FUNNEL I DID HERE
create table bi_category_funnel as
with category_funnel as (
  select
     category_id,
     user_id,
     max(viewed) as viewed,
     max(carted) as carted,
     max(purchased) as purchased
    from funnel_stages_detailed
    group by category_id, user_id
 )
select
category_id,
sum(viewed) as total_views,
sum(carted) as total_carted,
sum(purchased) as total_purchases
from category_funnel
group by category_id
order by total_views desc;

---THIS HERE IS FOR THE OVERALL SUMMARY WHICH CAN BE USED FOR THE KPI'S IN POWERBI
create table kpi_summary as
select
sum(viewed) as total_views,
sum(carted) as total_carted,
sum(purchased) as total_purchases,
sum( carted)*100/ NULLIF(sum(viewed),0) as view_to_cart_percentage,
sum( purchased)*100/ NULLIF(sum(carted),0) as cart_to_purchase_percentage,
sum( purchased)*100/ NULLIF(sum(viewed),0) as view_to_purchase_percantage,
sum(viewed)-sum(carted) as view_carted_dropoff,
sum(carted)-sum(purchased) as cart_purchase_dropoff

from funnel_stages;








