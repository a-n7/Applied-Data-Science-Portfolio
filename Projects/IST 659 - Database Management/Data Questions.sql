use movies 
GO
drop view if exists budget 
go 

---higest rated movie 
select m.movietitle, m.genre, a.firstname + ' ' + a.lastname as main_actor, p.firstname + ' ' + p.lastname as director, 
avg(criticrating) as criticrating,
avg(fanrating) as fanrating
from  movies m, ratings r, persons p, moviecast mc , persons a
where m.movieid=r.movieid
and m.director = p.personid
and mc.actorid = a.personid
and mc.movietitle = m.movietitle 
and mc.role = 'Main Actor'
group by m.movietitle, m.genre, p.firstname, p.lastname , a.firstname, a.lastname
order by criticrating desc 



--Budget Classification 
drop view if exists budgetinfo
GO 

create view budgetinfo as (
select movietitle, initial_budget, actual_budget, total_revenue,
(case 
    when initial_budget > actual_budget then 'Under Budget'
    when initial_budget < actual_budget then 'Over Budget'
    else 'On Budget Target' 
    end) 'Budget_Category',
(case 
    when total_revenue < 0 then 'No Profit'
    when total_revenue > 0 then 'Profit'
    else 'Breakeven'
    end)  'Profit'
from budget 
)
GO 

select * from movies   

--movie budget performance & ratings
select r.movieid, b.movietitle, m.genre, 
b.initial_budget, b.actual_budget, b.initial_budget -  b.actual_budget as budget_diff,
b.budget_category, b.total_revenue, b.profit,
avg(fanrating) over (partition by b.movietitle) as fanrating,
avg(criticrating) over (partition by b.movietitle) as criticrating
 from budgetinfo b, ratings r, movies m
where m.movieid=r.movieid
and b.movietitle = m.movietitle
and b.profit = 'No Profit'




--genre info avg
select distinct m.genre,
avg(fanrating) over (partition by m.genre) as avg_fanrating,
avg(criticrating) over (partition by m.genre) as avg_criticrating,
avg(f.rentalrate) over (partition by m.genre) as avg_location_rentalrate,
avg(f.num_of_days) over (partition by m.genre) as avg_filming_days,
avg(runtime) over (partition by m.genre) as avg_runtime,
avg(p.rate) over (partition by m.genre) as avg_director_cost
from movies m, ratings r , filmschedule f, persons p
where m.movieid = r.movieid 
and m.movietitle = f.movietitle
and p.personid=m.director
group by m.genre, r.fanrating, r.criticrating, f.rentalrate, f.num_of_days, m.runtime, p.rate




--location days
drop view if exists filmschedule
go 
create view filmschedule as(
select locationtype, movietitle, rentalrate, date_in, date_out, datediff(day, date_in, date_out) as num_of_days 
from filmlocations )
go 

select * from filmschedule 


--which movies take the longest to film?
select movietitle,
sum(rentalrate) over (partition by movietitle) as total_location_rentalrate,
sum(num_of_days) over (partition by movietitle) as total_filming_days
from filmschedule 
order by total_filming_days desc


--average cost and average filming days per category
select distinct m.genre,
avg(f.rentalrate) over (partition by m.genre) as total_location_rentalrate,
avg(f.num_of_days) over (partition by m.genre) as total_filming_days
from filmschedule f, movies m
where m.movietitle = f.movietitle
order by  total_filming_days desc

--number of movies by ear
select  m.yearrelease ,
count(m.yearrelease) movies_per_year
from movies m
group by m.yearrelease

--select m.director, d.firstname, d.lastname,
--mc.actorid, a.firstname, a.lastname 
--from moviecast mc, movies m, persons d
--left join persons a on a.personid = mc.actorid
--where m.movietitle=mc.movietitle
--and d.personid=m.director










select * from filmlocations where movietitle = '1st Grade'
select * from budget
order by total_revenue 

with user_ratings as ( 
select distinct u.user_firstname, u.user_lastname,
count(r.rating_for_user_id) over (partition by r.rating_for_user_id) as count_rating,
avg(cast(r.rating_value as decimal)) over (partition by r.rating_for_user_id) as avg_rating,
avg(cast(r.rating_value as decimal)) over (partition by r.rating_astype) as overall_rating_avg
from vb_user_ratings r
join vb_users u on u.user_id = r.rating_for_user_id
where r.rating_astype = 'Seller'
)
select *, (avg_rating - overall_rating_avg) as diff_from_avg
from user_ratings


--location rental rates
select locationtype, sum(rentalrate) as total_rentalrate
from filmlocations  
group by locationtype
order by total_rentalrate desc ; 


--Budget Classification 
select movietitle, initial_budget, actual_budget,
(case 
    when actual_budget > 0 then 'Under Budget'
    when actual_budget < 0 then 'Over Budget'
    else 'On Budget Target' 
    end) 'Budget Classification'
from budget 



select m.movietitle, r.website, r.fanrating, r.criticrating
from movies m, ratings r 
where m.movieid = r.movieid 


select r.website, avg(r.fanrating) as fanrating, avg(r.criticrating) as criticrating
from ratings r 
group by r.website





use movies 
go 


drop view if exists budget 
go 


create view budget as 


with moviebudget as (
select distinct mc.movietitle, m.budget,
sum(p.rate) over (partition by mc.movietitle) as actorcost,
d.rate as directorcost,
fl.rentalrate as locationcost
from moviecast mc , movies m , persons p, filmlocations fl, persons d 
where mc.movietitle = m.movietitle 
and p.personid = mc.actorid  
and d.personid = m.director
and fl.movieid=m.movieid 
group by mc.movietitle , m.budget , mc.actorid, p.rate , d.rate , fl.rentalrate, m.movietitle, fl.movietitle
)
select distinct mb.movietitle, m.genre, actorcost, directorcost, locationcost, mb.budget as initial_budget,
(sum(actorcost + directorcost + locationcost) over (partition by mb.movietitle,m.movietitle)) as actual_budget, 
m.revenue as theater_revenue,
(m.revenue - sum(mb.budget - actorcost + directorcost + locationcost) over (partition by m.movietitle)) as total_revenue

from moviebudget mb
left join movies m on mb.movietitle = m.movietitle 
GO





select sum(rentalrate) over (partition by movietitle) from filmlocations  where movietitle = 'Adventures at Night'
select * from budget 

select distinct m.movietitle,
 sum(p.rate) over (partition by m.movietitle) , s.director, d.rate
from moviecast m, persons p, movies s, persons d
where p.personid = m.actorid 
and d.personid = s.director
and s.movietitle = m.movietitle 
group by m.movietitle, s.director, d.rate, p.rate 


