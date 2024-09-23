use hospitalitydb;
-------------------------------------# KPIs --------------------------------------------------------------

------------#Total revenue, Total booking, Total no of guest, Total ratings given, Avg rating given, ADR
select sum(revenue_realized) as 'Total Revenue', count(booking_id) as 'Total_Booking',sum(no_guests) as "Total No of Guests", sum(ratings_given) as "Total ratings given",
avg(ratings_given) as "Avg rating given", sum(revenue_realized)/count(booking_id) as "ADR" from fact_bookings;

------------#Total succesful Booking, Total capacity, Occupancy % --------------------------------------------------------------
Select sum(successful_bookings) as "Total sucessfull Bookings ", sum(capacity) as "Total Capacity", (sum(successful_bookings)/sum(capacity)) * 100 as "Occupancy %"
from fact_aggregated_bookings;

 -------------------------------------------------------------#Total no of Days --------------------------------------------------------------
select datediff(max(dates),min(dates)) + 1 as "Total no of Days" from dim_date;

------------------#Total cancelled bookings, Total No show booking, Total Checked out

select  
	sum(case when booking_status = 'Cancelled' then 1 else 0 end) as Total_cancelled_bookings,
    sum(case when booking_status = 'No Show' then 1 else 0 end) as Total_noShow_bookings,
    sum(case when booking_status = 'Checked Out' then 1 else 0 end) as Total_checkedOut_bookings
from fact_bookings;

 -------------------------------------------------------------# RevPAR  --------------------------------------------------------------
select sum(fb.Total_revenue)/sum(fab.total_capacity) as "RevPAR"
from (
		select check_in_date, sum(revenue_realized) as Total_revenue
        from fact_bookings 
        group by check_in_date) as fb
join (
		select check_in_date, sum(Capacity) as Total_capacity
        from fact_aggregated_bookings
        group by check_in_date) as fab 
on fb.check_in_date = fab.check_in_date;

 -------------------------------------------------------------# Cancellation %  --------------------------------------------------------------

select (count(case when booking_status = "Cancelled" then booking_id end)/ count(booking_id)) * 100 as "Cancellation %"
from fact_bookings;
    
-------------------# No show  %  --------------------------------------------------------------

select (count(case when booking_status = "No Show" then booking_id end)/ count(booking_id)) * 100 as "Cancellation %"
from fact_bookings;

----------------------------# Realisation  %  --------------------------------------------------------------

select (count(case when booking_status = "Checked Out" then booking_id end)/ count(booking_id)) * 100 as "Cancellation %"
from fact_bookings;

----------------------------# QA graphs   --------------------------------------------------------------

use hospitalitydb;
-------------------------------------------# Page 1 Revenue QA--------------------------------------------------------------------------
## Revenue by Booking platform ##
select booking_platform as Booking_Platform, sum(revenue_realized) as Total_revenue
from fact_bookings 
group by booking_platform;

## Revenue by city ##
select dh.city as City, sum(fb.revenue_realized) as Total_revenue
from fact_bookings as fb
left join dim_hotels as dh
on fb.property_id = dh.property_id
group by dh.city;

## Revenue by property name ##
select dh.property_name as Property_name, sum(fb.revenue_realized) as Total_revenue
from fact_Bookings as fb 
left join dim_hotels as dh
on fb.property_id = dh.property_id
group by dh.property_name;

## revenue by day type ##
select dd.day_type as Day_type, sum(fb.revenue_realized) as Total_revenue
from fact_bookings as fb 
left join dim_date as dd 
on fb.check_in_date = dd.dates
group by dd.day_type;

# revenue by week no
select dd.week_no as Week_No, sum(fb.revenue_realized) as Total_revenue
from fact_bookings as fb 
left join dim_date as dd 
on fb.check_in_date = dd.dates
group by dd.week_no;

## revenue by month ##
select dd.mmm_yy as Month_name, sum(fb.revenue_realized) as Total_revenue
from fact_bookings as fb 
left join dim_date as dd 
on fb.check_in_date = dd.dates
group by dd.mmm_yy;

## revenue by room class ##
select dr.room_class as Room_class, sum(fb.revenue_realized) as Total_revenue
from fact_bookings as fb 
left join dim_rooms as dr 
on fb.room_category = dr.room_id
group by dr.room_class;

-------------------------------------------------# Page 2 Occuapncy---------------------------------------------------------------
## Occupancy by months ##
select dd.mmm_yy, sum(fab.successful_bookings) as Total_successful_bookings,sum(fab.capacity) as Total_capacity,
(sum(fab.successful_bookings)/sum(fab.capacity)) * 100 as Occuapncy_percent
from fact_aggregated_bookings as fab
join dim_date as dd
on fab.check_in_date = dd.dates
group by dd.mmm_yy;

## Occupancy by daytype ##
select dd.day_type, sum(fab.successful_bookings) as Total_successful_bookings,sum(fab.capacity) as Total_capacity,
(sum(fab.successful_bookings)/sum(fab.capacity)) * 100 as Occuapncy_percent
from fact_aggregated_bookings as fab
join dim_date as dd
on fab.check_in_date = dd.dates
group by dd.day_type;

## Occupancy by Week_no ##
select dd.week_no, sum(fab.successful_bookings) as Total_successful_bookings,sum(fab.capacity) as Total_capacity,
		(sum(fab.successful_bookings)/sum(fab.capacity)) * 100 as Occuapncy_percent
from fact_aggregated_bookings as fab
join dim_date as dd
on fab.check_in_date = dd.dates
group by dd.week_no;

## Occupancy by Property name ##
select dh.property_name, sum(fab.successful_bookings) as Total_successful_bookings, sum(fab.capacity) as Total_capacity,
(sum(fab.successful_bookings)/sum(fab.capacity)) * 100 as Occuapncy_percent
from fact_aggregated_bookings as fab 
left join dim_hotels as dh
on fab.property_id = dh.property_id 
group by dh.property_name;

## Occupancy by city ##
select dh.city, sum(fab.successful_bookings) as Total_successful_bookings, sum(fab.capacity) as Total_capacity,
(sum(fab.successful_bookings)/sum(fab.capacity)) * 100 as Occuapncy_percent
from fact_aggregated_bookings as fab 
left join dim_hotels as dh
on fab.property_id = dh.property_id 
group by dh.city;

## Occupancy by room class ##
select dr.room_class, sum(fab.successful_bookings) as Total_successful_bookings, sum(fab.capacity) as Total_capacity,
(sum(fab.successful_bookings)/sum(fab.capacity)) * 100 as Occuapncy_percent
from fact_aggregated_bookings as fab 
left join dim_rooms as dr
on fab.room_category = dr.room_id
group by dr.room_class;


------------------------------------------------------# Page 3 Booking Status--------------------------------------------------------

## Booking status by months ##
select dd.mmm_yy as Month_name,
	sum(case when fb.booking_status = "Cancelled" then 1 else 0 end) as Total_cancellation,
    sum(case when fb.booking_status = "No Show" then 1 else 0 end) as Total_noShow,
	sum(case when fb.booking_status = "Checked Out" then 1 else 0 end) as Total_checked_out,  
    count(fb.booking_id) as Total_bookings
from fact_bookings as fb 
join dim_date as dd
on fb.check_in_date = dd.dates
group by dd.mmm_yy;

## Booking Status by day type ##
select dd.day_type,
	sum(case when fb.booking_status = "Cancelled" then 1 else 0 end) as Total_cancellation,
    sum(case when fb.booking_status = "No Show" then 1 else 0 end) as Total_noShow,
	sum(case when fb.booking_status = "Checked Out" then 1 else 0 end) as Total_checked_out,  
    count(fb.booking_id) as Total_bookings
from fact_bookings as fb 
join dim_date as dd
on fb.check_in_date = dd.dates
group by dd.day_type;

## Booking Status by day type ##
select dd.week_no,
	sum(case when fb.booking_status = "Cancelled" then 1 else 0 end) as Total_cancellation,
    sum(case when fb.booking_status = "No Show" then 1 else 0 end) as Total_noShow,
	sum(case when fb.booking_status = "Checked Out" then 1 else 0 end) as Total_checked_out,  
    count(fb.booking_id) as Total_bookings
from fact_bookings as fb 
join dim_date as dd
on fb.check_in_date = dd.dates
group by dd.week_no;
                
## booking status by property name ##
select
	dh.property_name,
    sum(case when fb.booking_status = "Cancelled" then 1 else 0 end) as Total_cancellation,
    sum(case when fb.booking_status = "No Show" then 1 else 0 end) as Total_noShow,
    sum(case when fb.booking_status = "Checked Out" then 1 else 0 end) as Total_checked_out,
    count(fb.booking_id) as Total_booking
from fact_bookings as fb 
join dim_hotels as dh 
on fb.property_id = dh.property_id 
group by dh.property_name;

## Booking status by city ##
select
	dh.city,
    sum(case when fb.booking_status = "Cancelled" then 1 else 0 end) as Total_cancellation,
    sum(case when fb.booking_status = "No Show" then 1 else 0 end) as Total_noShow,
    sum(case when fb.booking_status = "Checked Out" then 1 else 0 end) as Total_checked_out,
    count(fb.booking_id) as Total_booking
from fact_bookings as fb 
join dim_hotels as dh 
on fb.property_id = dh.property_id 
group by dh.city;

## booking status by room class ## 
select dr.room_class,
	sum(case when fb.booking_status = "Cancelled" then 1 else 0 end) Total_cancellation,
    sum(case when fb.booking_status = "No Show" then 1 else 0 end) as Total_noShow,
    sum(case when fb.booking_status = "Checked Out" then 1 else 0 end) as Total_checked_out,
    count(fb.booking_id) as Total_bookings
from fact_bookings as fb
join dim_rooms as dr
on fb.room_category = dr.room_id
group by dr.room_class;

## booking status by booking platform ## 
select booking_platform,
	sum(case when booking_status = "Cancelled" then 1 else 0 end) Total_cancellation,
    sum(case when booking_status = "No Show" then 1 else 0 end) as Total_noShow,
    sum(case when booking_status = "Checked Out" then 1 else 0 end) as Total_checked_out,
    count(booking_id) as Total_bookings
from fact_bookings 
group by booking_platform;


-------------------------------------------------# Page 4.1 Total-no-of-guest QA--------------------------------------------
## No of guest by booking platform ##
select booking_platform as Booking_Platform, sum(no_guests) as Total_no_of_guests
from fact_bookings 
group by booking_platform;

## No of guest by city  ##
select dh.city as City, sum(no_guests) as Total_no_of_guests
from fact_bookings as fb
join dim_hotels as dh
on fb.property_id = dh.property_id
group by dh.city;

## No of guest by property name ##
select dh.property_name as Property_name, sum(no_guests) as Total_no_of_guests
from fact_Bookings as fb 
join dim_hotels as dh
on fb.property_id = dh.property_id
group by dh.property_name;

## No of guest by day type ## 
select dd.day_type as Day_type, sum(no_guests) as Total_no_of_guests
from fact_bookings as fb 
join dim_date as dd 
on fb.check_in_date = dd.dates
group by dd.day_type;

## No of guest by months ## 
select dd.mmm_yy as Month_name, sum(no_guests) as Total_no_of_guests
from fact_bookings as fb 
join dim_date as dd 
on fb.check_in_date = dd.dates
group by dd.mmm_yy;

## No of guest by room class  ## 
select dr.room_class as Room_class, sum(no_guests) as Total_no_of_guests
from fact_bookings as fb 
join dim_rooms as dr 
on fb.room_category = dr.room_id
group by dr.room_class;


----------------------------------# 4.2 total no of ratings-------------------------------------------------------------
## Total no of rating given by booking platform ##
select booking_platform as Booking_Platform, sum(ratings_given) as Total_Ratings_given, avg(ratings_given) as Avg_Ratings_given
from fact_bookings 
group by booking_platform;

## Total no of rating given by city ##
select dh.city as City, sum(ratings_given) as Total_Ratings_given, avg(ratings_given) as Avg_Ratings_given
from fact_bookings as fb
join dim_hotels as dh
on fb.property_id = dh.property_id
group by dh.city;

## Total no of rating given by property name ## 
select dh.property_name as Property_name, sum(ratings_given) as Total_Ratings_given, avg(ratings_given) as Avg_Ratings_given
from fact_Bookings as fb 
join dim_hotels as dh
on fb.property_id = dh.property_id
group by dh.property_name;

## Total no of rating given by day type ## 
select dd.day_type as Day_type, sum(ratings_given) as Total_Ratings_given, avg(ratings_given) as Avg_Ratings_given
from fact_bookings as fb 
join dim_date as dd 
on fb.check_in_date = dd.dates
group by dd.day_type;

## Total no of rating given by months## 
select dd.mmm_yy as Month_name, sum(ratings_given) as Total_Ratings_given, avg(ratings_given) as Avg_Ratings_given
from fact_bookings as fb 
join dim_date as dd 
on fb.check_in_date = dd.dates
group by dd.mmm_yy;

## Total no of rating given by room class ## 
select dr.room_class as Room_class,sum(ratings_given) as Total_Ratings_given, avg(ratings_given) as Avg_Ratings_given
from fact_bookings as fb 
join dim_rooms as dr 
on fb.room_category = dr.room_id
group by dr.room_class;