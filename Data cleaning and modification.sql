use hospitalitydb;
------------------------------------------ # data cleaning & modification on table dim_date 
select *from dim_date;
describe dim_date;
------------# rename the columns names
alter table dim_date rename column `mmm yy`to mmm_yy;
alter table dim_date rename column `week no` to week_no;
alter table dim_date rename column date to dates;
------------# checking if any null values in the table
select *from dim_date 
where dates is null 
	or mmm_yy is null 
    or  week_no is null 
    or day_type is null;
------------# checking if there any duplicate row in the table
select *from dim_date
where (dates, mmm_yy, week_no, day_type) IN 
	(select dates, mmm_yy, week_no, day_type
    from dim_date
    group by dates, mmm_yy, week_no, day_type
    having count(*) >1 
    );
------------#  fixing the typing error in the data 
set SQL_SAFE_UPDATES = 0;
update dim_date 
set day_type = 'weekday'
where day_type = 'weekeday';
------------# adding constrainst to the table 
alter table dim_date
modify dates date not null;

alter table dim_date
modify column mmm_yy char(6) not null;

alter table dim_date
modify column week_no char(4) not null;

alter table dim_date
modify column day_type enum('weekday','weekend') not null;

------------# changing the format of the date 
select date_format(str_to_date(dates, '%d-%b-%y'), '%Y-%m-%d') as formatted_date from dim_date;
update dim_date
set dates = date_format(str_to_date(dates,'%d-%b-%y'),'%Y-%m-%d');

-------- -----------------------------------# data cleaning & modification on table dim_hotels
select *from dim_hotels;
describe dim_hotels;
------------# checking if there any null values in the column
select *from dim_hotels
where property_id is null;
------------# checking if there is any null values in the column or row
select *from dim_hotels
where property_name is null
	or property_name is null
    or category is null
    or city is null;
------------# deleting the null values 
delete from dim_hotels 
where property_name is null
	or property_name is null
    or category is null
    or city is null;
------------# checking if there any duplicates rows 
select *from dim_hotels
where(property_id, property_name, category, city) in 
	(select property_id, property_name, category, city 
    from dim_hotels
    group by property_id, property_name, category, city
    having count(*) >1 
    );

------------# modify datatype of the table and adding the constraint to it 
alter table dim_hotels
modify column property_id char(5);

alter table dim_hotels
modify column property_name varchar(50) not null;

alter table dim_hotels
modify column category enum('Luxury','Business') default 'Business';

alter table dim_hotels
modify  column city varchar(18) not null;

select property_id, count(*) as counta
from dim_hotels
group by property_id 
having counta > 1;
alter table dim_hotels
add primary key (property_id);


-------- -----------------------------------# data cleaning & modification on table dim_rooms
select *from dim_rooms;
describe dim_rooms;
------------# checking if there any nulls values in rows or columns 
select *from dim_rooms 
where room_id is null 
	or room_class is null;
------------# checking if there any duplicate row 
select *from dim_rooms 
where (room_id, room_class) in 
	(select room_id, room_class 
    from dim_rooms 
    group by room_id, room_class
    having count(*) > 1
    );
------------# modifying the datatype of column and adding constrainst to it 
alter table dim_rooms
modify column room_id char(3) primary key;

alter table dim_rooms
modify column room_class varchar(15) not null;


-------- -----------------------------------# data cleaning & modification on table dim_fact_aggregated_booking
select *from fact_aggregated_bookings;
describe fact_aggregated_bookings;
------------# checking if there any nulls values in rows or columns 
select *from fact_aggregated_bookings
where property_id is null
	or check_in_date is null
    or room_category is null 
    or successful_bookings is null 
    or capacity is null;
------------# checking if there any duplicate row 
SELECT a.*
FROM fact_aggregated_bookings a
JOIN (
    SELECT property_id, check_in_date, room_category, successful_bookings, capacity
    FROM fact_aggregated_bookings
    GROUP BY property_id, check_in_date, room_category, successful_bookings, capacity
    HAVING COUNT(*) > 1
) b
ON a.property_id = b.property_id
AND a.check_in_date = b.check_in_date
AND a.room_category = b.room_category
AND a.successful_bookings = b.successful_bookings
AND a.capacity = b.capacity;
------------# modifying the datatype of column and adding constrainst to it 
alter table fact_aggregated_bookings
modify column property_id char(5);
alter table fact_aggregated_bookings
add constraint fk_property_id foreign key (property_id) references dim_hotels(property_id);

update fact_aggregated_bookings 
set check_in_date = date_format(str_to_date(check_in_date,'%d-%b-%y'),'%Y-%m-%d');

alter table fact_aggregated_bookings 
modify column room_category char(3);

alter table fact_aggregated_bookings
add constraint fk_room_category foreign key (room_category) references dim_rooms(room_id);


-------- -----------------------------------# data cleaning & modification on table fact_bookings
select *from fact_bookings;
describe fact_bookings;
------------# checking if there any nulls values in rows or columns 
select *from fact_bookings
where booking_id is null
	or property_id is null
	or booking_date is null
	or check_in_date is null
	or checkout_date is null
	or no_guests is null
	or room_category is null
	or booking_platform is null
	or ratings_given is null
	or booking_status is null
	or revenue_generated is null
	or revenue_realized is null;
------------# checking if there any empty values in rows or columns 
SELECT *
FROM fact_bookings
WHERE booking_id = ''
   OR property_id = ''
   OR booking_date = ''
   OR check_in_date = ''
   OR checkout_date = ''
   OR no_guests = ''
   OR room_category = ''
   OR booking_platform = ''
   OR ratings_given = ''
   OR booking_status = ''
   OR revenue_generated = ''
   OR revenue_realized = '';
   
select ratings_given as mode_1, count(*)
from fact_bookings
group by ratings_given
order by count(*) desc;
------------# replacing the empty values to null values 
update fact_bookings 
set ratings_given = null 
where ratings_given = '';
------------# checking if there any duplicate row 
select a.* from fact_bookings as a
join (
		select booking_id, property_id, booking_date, check_in_date, checkout_date, no_guests, room_category, booking_platform, ratings_given, booking_status, 
        revenue_generated, revenue_realized
        from fact_bookings 
        group by booking_id, property_id, booking_date, check_in_date, checkout_date, no_guests, room_category, booking_platform, ratings_given, booking_status, 
        revenue_generated, revenue_realized
        having count(*) > 1 
	) as b 
ON a.booking_id = b.booking_id
   AND a.property_id = b.property_id
   AND a.booking_date = b.booking_date
   AND a.check_in_date = b.check_in_date
   AND a.checkout_date = b.checkout_date
   AND a.no_guests = b.no_guests
   AND a.room_category = b.room_category
   AND a.booking_platform = b.booking_platform
   AND a.ratings_given = b.ratings_given
   AND a.booking_status = b.booking_status
   AND a.revenue_generated = b.revenue_generated
   AND a.revenue_realized = b.revenue_realized;
------------# modifying the datatype of column and adding constrainst to it 
alter table fact_bookings 
modify column booking_date date,
modify column check_in_date date,
modify column checkout_date date;

alter table fact_bookings
modify column booking_id varchar(25) primary key;

alter table fact_bookings
modify column property_id char(5);
alter table fact_bookings
add constraint fk_property_id2 foreign key (property_id) references dim_hotels(property_id);

alter table fact_bookings
modify column room_category char(3);
alter table fact_bookings 
add constraint fk_room_category2 foreign key (room_category) references dim_rooms(room_id);

alter table fact_bookings
modify column booking_platform varchar(20);

alter table fact_bookings 
modify column booking_status enum('No Show','Checked Out','Cancelled');

alter table fact_bookings 
modify column ratings_given decimal(2,1);