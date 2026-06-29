---I FOUND A DECENT DATA SET ON KAGGLE ABOUT ECOMMERCE EVENTS, THAT WOULD BE PERFECT FOR A FUNNEL
---THE DATASET HAD 4 DIFFERENT FILES FOR MONTHS FROM OCT 19- FEB-20
---PROCEEDED TO DOWNLOAD THE DATA SET AND MANUALLY LOADED THEM POSTGRES 


---AFTER LOADING THE TABLES I WANTED TO COMBINE THE DATA SETS INTO ONE THING USING THE UNION FUNCTION..
create table all_events as
select * 
from events_oct
union all
select * 
from events_nov_raw
union all
select * 
from events_dec_raw
union all
select * 
from events_jan_raw
union all
select * 
from events_feb_raw;

---I RAN INTO A PROBLEM WHERE  SOME DATA SETS WHERE ALREADY ASSIGNED TO SPECIFIC DATATYPES e.g VARCHAR,BIGINT,TIMESTAMP
--- SO THE UNION FUNCTION RETURNED AN ERROR
---SO I PROCEEDED TO DROP THE TABLES AND START AFRESH
---INSTEAD I FORMATTED THE TABLES BY CREATING THEM BEFORE IMPORTING THE DATA

create table events_oct(
	event_type TEXT,
	event_time TEXT,
	product_id TEXT,
	category_id TEXT,
	category_code TEXT,
	brand TEXT,
	price TEXT,
	user_id TEXT,
	user_session TEXT
);

create table events_nov_raw(
	event_type TEXT,
	event_time TEXT,
	product_id TEXT,
	category_id TEXT,
	category_code TEXT,
	brand TEXT,
	price TEXT,
	user_id TEXT,
	user_session TEXT
);

create table events_dec_raw(
	event_type TEXT,
	event_time TEXT,
	product_id TEXT,
	category_id TEXT,
	category_code TEXT,
	brand TEXT,
	price TEXT,
	user_id TEXT,
	user_session TEXT
);

create table events_jan_raw(
	event_type TEXT,
	event_time TEXT,
	product_id TEXT,
	category_id TEXT,
	category_code TEXT,
	brand TEXT,
	price TEXT,
	user_id TEXT,
	user_session TEXT
);

create table events_feb_raw(
	event_type TEXT,
	event_time TEXT,
	product_id TEXT,
	category_id TEXT,
	category_code TEXT,
	brand TEXT,
	price TEXT,
	user_id TEXT,
	user_session TEXT
);

--- AFTER I THEN IMPORTED THE DATA TO THEIR SPECIFIC TABLES , ALL THE DATA WILL BE FORMATED TO TEXT DATATYPE IN THEIR TABLES WHICH WILL MAKE IT EASY FOR ME TO COMBINE THEM.

create table all_events as 
	select * 
from events_oct
union all
select * 
from events_nov_raw
union all
select * 
from events_dec_raw
union all
select * 
from events_jan_raw
union all
select * 
from events_feb_raw;

----NOW TO INSPECT THE DATA
---I NOTICED SPACING ISSUES WITH THE DATA AND ID LIKE TO SEE HOW IT WOULD IF I FIX IT
---BUT FIRST I WANT TO SEE HOW THE OUTCOME WILL LOOK

with space_correction as (     ---i used the with function for a temporary look, its not permanent
	select
		event_type,
		event_time,   
     	trim(product_id)as product_id, --- THE TRIM FUNCTION HELPS WITH SPACING BEFORE/AFTER THE STRING AND PUTS IT ON THE LEFT SIDE OF THE COLUMN
     	category_id,
     	brand, 
     	trim(price)as price,
     	trim(user_id)as user_id,
     	user_session
 from all_events
 )
 select * 
 from space_correction;
-- IT DEFINETLY LOOKS CLEANER SO I WILL UTILISE IT AFTER INSPECTING OTHER THINGS

---so i also noticed a bunch of duplicates that i will have to fix ,first i need to be sure of everything before i proceed.

--i used that counts exact column details that appear more than once, instead of the usual user id check this is based on an ecommerece site and users will use the website more than once so this query accounts for time too
---everything it accounts for makes it easier to identify duplicates cause a user id cant be doing the same thing on the same time and it registers twice, its clearly a system mistake.
select user_id, event_type, product_id, event_time, COUNT(*)
from all_events
group by user_id, event_type, product_id, event_time
having COUNT(*) > 1;


with how_many AS (
    select *,
    row_number() over (
    partition by user_id, event_type, product_id, event_time
    order by event_time
    ) as row_numb ,
    count(*) over (
        partition by user_id, event_type, product_id, event_time
    ) as duplicate_times
	from all_events
)
select*
from how_many
where duplicate_times>1
order by user_id, event_type, product_id, event_time;

--I WROTE THIS QUERY BELOW TO SEE THE DIFFERENCE BEFORE AND AFTER THE REMOVAL OF DUPLICATIONS
/*with how_many AS (
    select *,
    row_number() over (
    partition by user_id, event_type, product_id, event_time
    order by event_time
    ) as row_numb ,
    count(*) over (
        partition by user_id, event_type, product_id, event_time
    ) as duplicate_times
	from all_events
)
select
    (select count(*) from all_events) as before_removal,
    (select count(*) from how_many where row_numb = 1) as after_removal,
    (select count(*) from all_events) - (select count(*) from how_many where row_numb = 1) as duplicates_removed   
from how_many
limit 1;*/

---NOW THAT IVE SEEN THE DUPLICATES AND THE TRIM DIFFERENCE I WILL PROCEED TO MAKE A NEW TABLE WHERE EVERYTHING IS FIXED.
create table clean_events as 
with how_many AS (
    select *,
    row_number() over (
    partition by user_id, event_type, product_id, event_time  --- IN A WAY I USED THE SAME QUERIES THAT DID MY CLEANING AND DUPLICATION FIX , TO CREATE A NEW CLEAN EVENTS TABLE
    order by event_time
    ) as row_numb ,
    count(*) over (
        partition by user_id, event_type, product_id, event_time
    ) as duplicate_times
	from all_events
)
select
	event_type,
	event_time,   
     trim(product_id)as product_id,
     category_id,
     brand, 
     trim(price)as price,
     trim(user_id)as user_id,
     user_session
 from how_many
where row_numb=1;

---NOW THAT I CREATED MY CLEAN EVENTS TABLE 
-- I FORGOT TO ASSIGN DATA TYPES WHILE CREATING THE TABLE
--SO I HAVE TO ASSIGN DIFFERENT DATATYPES TO THE COLUMNS , THIS WILL MAKE IT EASY FOR CERTAIN QUERIES AND CALCULATION LATER ON


---THOSE ARE THE MAIN DATATYPES I USED.
alter table clean_events 
	alter column event_type type varchar using event_type::varchar(20),---VARCHAR FOR COLUMS THAT HAVE LETTERS,EMAILS,NAME ETC.
	alter column event_time type timestamp using event_time::timestamp,---TIMESTAMP FOR REGISTRATION TIME,DATE etc
	alter column product_id type bigint using product_id::bigint,
	alter column category_id type bigint using category_id::bigint,
	---the number in the bracket is for the character limit..basically choosing the max characters for the column
	alter column brand type varchar using brand::varchar(20),
	alter column price type decimal using price::decimal,---this will accomodate prices/numbers with or without decimals
	alter column user_id type bigint using user_id::bigint,---BIGINT FOR NUMBERS,IDs 
	alter column user_session type varchar using user_session::varchar(50);
---THERE IS A WAY TO CHANGE THE DATA TYPE ON POSTGRE , BY TABLE PROPERTIES
---THATS WHERE I ALSO PROPERLY LEARNED IT BY LOOKING AT THE SQL QUERY
---THE QUERY DOES TAKE A BIT OF TIME TO LOAD THOUGH

---SUMMARY
---I CREATED TABLES, USED IMPORT WIZARD TO IMPORT THE DATA
---ASSIGNED THE DATATYPES TO TEXT TO MAKE IT EASY TO UNION THE TABLES
---USED UNION SUCCESFULLY
---INSPECTED THE DATA, TRIMED AND CHECKED FOR DUPLICATES
---THEN ASSIGNED THE TALES TO TEHRI RIGHTFULL DATATYPES USING THE ALTER FUNCTION




















