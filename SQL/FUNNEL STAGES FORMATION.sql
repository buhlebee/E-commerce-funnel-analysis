---THIS IS HOW I MANAGE EVRYTHING AFTER CLEANING THE DATA

---FROM RAW DATA TO CLEAN_EVENTS WHERE I NOW DO DIFFERENT ASSIGNMENTS


--QUICKLY ADDED A MONTH COLUMN , I FORGOT TO ,BUT THIS WILL MAKE IT EASIER TO DO SOME CALCULATIONS---
alter table clean_events
add column event_month varchar(7);

update clean_events 
set event_month= to_char(event_time,'YYYY-MM');-- INSTEAD OF COPYING THE WHOLE EVENT_DATE COLUMN THIS QUERY ONLY INCLUDES YEAR-MONTH HENCE YYYY-MM


---CREATED A DETAILED VERSION TO BE ABLE TO DO MORE CALCULATIONS e.g MONTHLY FUNNEL VIEWS
create table funnel_stages_detailed as 
select
	user_id,
	event_month,
	product_id,
	category_id,
	max (case when event_type='view'then 1 else 0 end) as viewed,
	max (case when event_type='cart'then 1 else 0 end) as carted,
	max(case when event_type='remove_from_cart'then 1 else 0 end)as removed,
	max (case when event_type='purchase'then 1 else 0 end) as purchased
from clean_events
group by user_id,
event_month,
product_id,
category_id;


---THIS IS MY FINAL FUNNEL TABLE WHERE I WILL DO THE MAIN CONVERSION CALCULATIONS
	create table funnel_stages as
	select
	user_id,
	max(case when event_type='view'then 1 else 0 end)as viewed,
	max(case when event_type='cart'then 1 else 0 end)as carted,
	max(case when event_type='remove_from_cart'then 1 else 0 end)as removed,
	max(case when event_type='purchase'then 1 else 0 end)as purchased
	from clean_events
	group by user_id;
	
