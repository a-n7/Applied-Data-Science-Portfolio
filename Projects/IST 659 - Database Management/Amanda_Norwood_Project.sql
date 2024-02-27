--drop database if exists movies; 
--GO
--create database movies;
--go
use movies;
GO
--- Down Script--- 
If exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	Where CONSTRAINT_NAME=' fk_movie_genre')
	Alter table movies drop constraint  fk_movie_genre

If exists(select*from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	WHERE CONSTRAINT_NAME= 'fk_movies_dir')
	Alter table movies drop constraint fk_movies_dir

If exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	Where CONSTRAINT_NAME='fk_movies_prodcompany')
	Alter table movies drop constraint fk_movies_prodcompany

If exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	Where CONSTRAINT_NAME='fk_ratings_movieid')
	Alter table ratings drop constraint fk_ratings_movieid

If exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	Where CONSTRAINT_NAME='fk_movie_cast_actor')
	Alter table moviecast drop constraint fk_movie_cast_actor

If exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	Where CONSTRAINT_NAME='fk_movie_movietitle')
	Alter table moviecast drop constraint fk_movie_movietitle

If exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	Where CONSTRAINT_NAME='fk_moviecast_role')
	Alter table moviecast drop constraint fk_moviecast_role

If exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	Where CONSTRAINT_NAME='fk_filmlocations_movietitle')
	Alter table filmlocations drop constraint fk_filmlocations_movietitle

If exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	Where CONSTRAINT_NAME='fk_filmlocations_locationtype')
	Alter table filmlocations drop constraint fk_filmlocations_locationtype
go
--- drop all tables
drop table if exists filmlocations
drop table if exists moviecast 
drop table if exists ratings 
drop table if exists locations
drop table if exists movies 
drop table if exists prodcompany
drop table if exists genres
drop table if exists persons
drop table if exists role
GO

---Drop all procedure
drop procedure if exists p_search_movies
drop procedure if exists p_search_person
drop procedure if exists p_search_flr
drop procedure if exists p_upsert_newmovie
drop procedure if exists p_upsert_updatemoviestable
drop procedure if exists p_upsert_criticrating
drop procedure if exists p_upsert_fanrating
drop procedure if exists p_upsert_filmlocationrentalrate
drop procedure if exists p_upsert_personsrate
GO


---Drop all views
drop view if exists budget 
drop view if exists totalRentalRatePerLocation
drop view if exists budgetinfo
drop view if exists filmschedule
GO
--------------------------------------------------------------------------------------------------------------
---CREATE ROLE TYPE TABLE

create table role (
    roleid int primary key identity,
    roletype varchar(50) not null,
    constraint u_role_roletype unique (roletype),
)
GO

---CREATE PERSONS TABLE
create table persons (
    personid int primary key identity not null,
    firstname varchar(50) not null,
    lastname varchar(50) not null,
    gender char(1) not null,
    rate money not null,
    constraint ck_persons_gender_m_or_f check (gender = 'M' OR gender ='F'),
    constraint ck_persons_firstname_length_gt_1 check (LEN(firstname)>1),
    constraint ck_persons_lastname_length_gt_1 check (LEN(lastname)>1)
)
GO

---CREATE GENRES TABLE
create table genres (
    genreid int primary key identity not null,
    genrename varchar(20) not null,
    constraint u_genres_genresname unique (genrename),
)
GO

---CREATE LOCATION TABLE
create table locations (
    locationid int primary key  identity not null,
    locationtype varchar(20) not null,
    city varchar(15) not null,
    state char(2) not null,
    constraint u_locations_locationtype unique (locationtype),
    constraint ck_locations_state_length check (LEN(state)=2)
)
GO

---CREATE PRODUCTION COMPANY
create table prodcompany (
    companyid int primary key identity not NULL,
    companyname varchar(20) not null,
    constraint u_prod_company_companyname unique (companyname)
)
GO

---CREATE MOVIES TABLE
create table movies(
    movieid int primary key identity not null,
    movietitle varchar(150) not null,
    genre varchar(20) not null,
    budget money not null,
    revenue money null,
    yearrelease char(4) null,
    runtime int null,
    prodcompany varchar(20) not null,
    director int not null, 
    constraint u_movies_movietitle unique (movieid,movietitle),
    constraint u_movies_movietitle_prodcompany unique (movietitle,prodcompany),
    constraint ck_movies_yearrelease_length check (LEN(yearrelease)=4 OR yearrelease = NULL),
    constraint ck_movies_runtime check (runtime>0),
    constraint fk_movies_prodcompany foreign key (prodcompany)
        references prodcompany(companyname),
    constraint fk_movies_dir foreign key (director)
        references persons(personid),
    constraint fk_movie_genre foreign key (genre)
		References genres(genrename)  
)
GO 

--Alter table movies
--	Add constraint fk_movies_prodcompany foreign key (prodcompany)
--        references prodcompany(companyname)
--    Alter table movies
 --   Add constraint fk_movies_dir foreign key (director)
  --      references persons(personid)
 --   Alter table movies
 --   Add constraint fk_movie_genre foreign key (genre)
--		References genres(genrename)  
--    GO  

---CREATE RATINGS TABLE
create table ratings (
    ratingid int primary key identity not null,
    movieid  int not null,
    website varchar(50) not null,
    fanrating int null,
    criticrating int null,
    check(fanrating >= 0 and fanrating <= 100),
    check(criticrating >= 0 and criticrating <= 100),
    constraint fk_ratings_movieid foreign key (movieid)
        references movies(movieid)
)
go
--Alter table ratings
	--Add constraint fk_ratings_movieid foreign key (movieid)
     --   references movies(movieid)
--go

---CREATE MOVIECAST TABLE
create table moviecast (
    castid int primary key identity not null,
    role varchar(50) not null,
    actorid int not null,
    movietitle varchar(150) not null,
    prodcompany varchar(20) not null,
    createdate DATETIME DEFAULT getdate()  , 
    constraint pk_moviecast_unique unique (role,actorid,movietitle),
    constraint pk_moviecast_unique_actor unique (actorid,movietitle),
    constraint fk_moviecast_role foreign key (role)
        references role(roletype),
    constraint fk_movie_movietitle foreign key (movietitle, prodcompany)
        references movies(movietitle, prodcompany),
    constraint fk_movie_cast_actor foreign key (actorid)
        references persons(personid)
)
GO

--Alter table moviecast
--Add constraint fk_moviecast_role foreign key (role)
 --       references role(roletype)
--Alter table moviecast
--Add constraint fk_movie_movietitle foreign key (movietitle, prodcompany)
  --      references movies(movietitle, prodcompany)
--Alter table moviecast
--Add constraint fk_movie_cast_actor foreign key (actorid)
 --       references persons(personid)
--GO  


---CREATE TABLE FILMLOCATIONS
create table filmlocations (
    locationid int primary key identity not NULL,
    locationtype varchar(20) not null,
    movieid int not null,
    movietitle varchar(150) not null,
    rentalrate money not null,
    date_in date null,
    date_out date null,    
    constraint pk_filmlocations_dates CHECK(date_in < date_out),
    constraint fk_filmlocations_locationtype foreign key (locationtype)
        references locations(locationtype),
    constraint fk_filmlocations_movietitle foreign key (movieid, movietitle)
        references movies(movieid,movietitle)
)
GO
--Alter table filmlocations
----Add constraint fk_filmlocations_locationtype foreign key (locationtype)
 --       references locations(locationtype)
--Alter table filmlocations
--Add constraint fk_filmlocations_movietitle foreign key (movieid, movietitle)
  --      references movies(movieid,movietitle)
--go
-------------------------------------------------------------------------------------------------------------
---insert into role
insert into role (roletype)
values 
    ('Main Actor'),
    ('Support Actor'),
    ('Director');

GO

---insert into persons table

insert into persons  (firstname, lastname, gender, rate)
values
    ('Luke','Brown','M',15000),
    ('Gabby','Smith','F',75000),
    ('Sam','Combs','M',100000),
    ('Taylor','Bryan','F',75000),
    ('Kane','Swift','M',60000),
    ('James','Conner','M',85000),
    ('Grace','Brady','F',120000),
    ('Cory','Jordan','M',90000),
    ('Alexa','Payne','F',75000),
    ('Marie','Styles','F',80000),
    ('Lionel','Brock','M',91000),
    ('Gillian','Song','F',65000),
    ('Johnnu','Skpe','M',10000),
    ('Bryanna','Kobe','F',75100),
    ('Joseph','Fox','M',80000),
    ('Erica','Connel','F',85000),
    ('Jennifer','Joestar','F',95000),
    ('Tommy','Peaches','M',50000),
    ('Ashley','Paul','F', 60350),
    ('Helena','Constintine','F',57670),
    ('Yessin','Bizzare','M',100000),
    ('Tiffany','Fortune','F',98000),
    ('Tristen','Demar','M',81000),
    ('Taeler','Taunts','F',43050),
    ('Lisa','Dotty','F',50250),
    ('Carmelo','Anthony','M',87000),
    ('Christina','Betencourt','F',67000),
    ('Ivan','Lopez','M',93000),
    ('Camron','Booker','M',96700),
    ('Lebron','James','M',175060)
GO

select * from persons

---insert into genres table

insert into genres (genrename)
values 
    ('Horror'),
    ('Love'),
    ('Action'),
    ('Family'),
    ('Comedy'),
    ('Drama'),
    ('Children'),
    ('Documentary')

GO

---insert into location table

insert into locations (locationtype, city, state)
values 
    ('Beach','Malibu','CA'),
    ('Coffee Shop','Los Angeles','CA'),
    ('Studio','Las Vegas','NV'),
    ('Park','Sacaramento','CA'),
    ('Apartment','Manahttan','NY'),
    ('Loft ','San Francisco','CA'),
    ('City Streets','Philiadelphia','PE'),
    ('Amusement Park','Orlando','FL'),
    ('Wedding Hall','Los Vegas','NV'),
    ('Dojo','Sacramento','CA'),
    ('Skyscrapers','Chicago','IL'),
    ('Cruise Line','Honolulu','HI'),
    ('Barren Field','Austin','TX'),
    ('Restaurant 1','Santa Barbara','CA'),
    ('Restaurant 2','Newport Beach.','CA'),
    ('Restaurant 3','New York City','NY'),
    ('Prison','Troy','NY'),
    ('Bedroom','Hollywood','CA'),
    ('Animation Studio','San Antonio','TX'),
    ('Custom Themed Studio','Hollywood','CA')
GO

---insert into prodcompany

insert into prodcompany (companyname)
values 
    ('Olive Butter'),
    ('Apple Sauce'),
    ('Visa Direct'),
    ('Three Kings'),
    ('Tiger Stripe'),
    ('Victory'),
    ('Atlantic Films'),
    ('Rest Well'),
    ('Film Club'),
    ('Rocket Movies'),
    ('MovieTime'),
    ('Popcorn Films'),
    ('Buttery PopCorn'),
    ('JawDrop'),
    ('IndyFilms'),
    ('Independent Network'),
    ('Happy Days'),
    ('Movies for All')
GO

---insert into movies table

insert into movies (movietitle, genre, budget, revenue, yearrelease, runtime,prodcompany,director)
VALUES
      ('New York Lights','Horror',200000,525690,2022,125,'Olive Butter',2),
    ('Singing at Night','Comedy',175000,429150,2020,165,'Apple Sauce',1),
    ('Dogs Asleep','Family',275000,918510,2014,95,'Visa Direct',6),
    ('Painting on the Wall','Action',150000,329430,2011,190,'Apple Sauce',8),
    ('Knock on the Door','Drama',300000,639180,2010,102,'Visa Direct',10),
     ('First Kiss','Love',400000,5256900,2022,105,'Three Kings',2),
    ('Adventures at Night','Children',375000,909150,2020,162,'Three Kings',1),
    ('Ottors','Documentary',275000,918510,2014,95,'Tiger Stripe',6),
    ('Wall of China','Documentary',150000,329430,2011,180,'Tiger Stripe',8),
    ('Knockdown Love','Love',300000,639180,2010,102,'Film Club',10),
     ('Young Bucks','Children',28000,825690,1999,115,'Victory',2),
    ('Desert Nights','Documentary',175000,523150,2016,190,'Atlantic Films',1),
    ('Cats Asleep','Documentary',275000,318510,2015,95,'Atlantic Films',6),
    ('Painting with Kat','Children',98000,629430,2014,100,'Rest Well',8),
    ('Knockdown Love, The Reunion','Love',400000,939180,2013,137,'Film Club',10),
     ('The Journal','Love',1300000,225690,2012,120,'Rocket Movies',2),
    ('NightWing','Action',175000,529330,2010,85,'MovieTime',1),
    ('The Killing','Horror',275000,1918510,2014,100,'MovieTime',6),
    ('Bachelors Party','Comedy',358000,784330,2019,110,'MovieTime',8),
    ('The Court','Drama',30000,983380,2000,80,'Popcorn Films',10),
     ('Love Hurts','Love',264080,7840320,2020,105,'Buttery PopCorn',2),
    ('Sing Bee Sing!','Children',95000,672915,2012,115,'Buttery PopCorn',1),
    ('Baseball','Documentary',275000,1918510,2022,135,'Buttery PopCorn',6),
    ('Paris','Documentary',80000,129430,2011,190,'JawDrop',8),
    ('Love at First Arrest','Love',630000,2334900,2015,102,'JawDrop',10),
     ('Red Light Blue Light','Children',50000,1025690,2002,45,'Victory',2),
    ('Space','Documentary',175000,4290980,2020,120,'Atlantic Films',1),
    ('MARS ROVERS','Documentary',275000,318450,2021,125,'Atlantic Films',6),
    ('Card Fight','Children',550000,3329430,2018,85,'Rest Well',8),
    ('Family Love','Love',430000,635430,2010, 60,'IndyFilms',10),
     ('Divorce Again?!','Love',200000,225690,2016,95,'IndyFilms',2),
    ('DayWing','Action',205000,320150,2001,95,'IndyFilms',1),
    ('Dont Fail','Horror',475000,4918510,2004,65,'IndyFilms',6),
    ('Family Guy','Comedy',150000,1329430,2011,90,'MovieTime',8),
    ('The Challenge','Drama',309200,2639180,2016,102,'Movies for All',10),
     ('Family Reunion','Family',267000,3525690,2017,55,'Movies for All',2),
    ('Santa Escape','Children',575000,5429150,2020,65,'Movies for All',1),
    ('IT Today','Documentary',235000,718000,2018,85,'Happy Days',6),
    ('City Paint','Documentary',950000,4299430,2009,90,'Happy Days',8),
    ('Love Knocks Twice','Love',100000,239180,2019,120,'Independent Network',10),
     ('New York Christmas','Family',200000,520090,2022,80,'Happy Days',2),
    ('American Pre-School','Family',175000,425000,2000,95,'Independent Network',1),
    ('Elements','Family',275000,780010,2021,100,'Atlantic Films',6),
    ('Teddy','Children',150000,809800,2010,85,'Rest Well',8),
    ('Supergirl','Action',300000,534180,2003,125,'Film Club',10),
     ('The Hill','Action',200000,1280090,2022,130,'Rocket Movies',2),
    ('Rangers','Action',175000,329150,2020,65,'MovieTime',1),
    ('Death by Sleep','Horror',275000,3318510,2014,105,'Olive Butter',6),
    ('L0L','Comedy',850000,3570000,2011,100,'Independent Network',8),
    ('The Election Campaign','Drama',200000,560080,2018,100,'Olive Butter',10),
     ('Love Lost','Love',600000,1525690,2009,50,'Apple Sauce',2),
    ('1st Grade','Children',375000,429150,2015,65,'Apple Sauce',1),
    ('Runaway','Drama',275000,604510,2004,75,'Apple Sauce',6),
    ('Family Vacation','Family',150000,390520,2022,80,'Visa Direct',8),
    ('Lovers','Love',600000,639180,2022,55,'Visa Direct',10),
     ('Dora','Children',2000000,5925690,2021,60,'Visa Direct',2),
    ('Minions','Family',1750000,7429150,2021,65,'Visa Direct',1),
    ('Apples of the World','Documentary',975000,1851000,2013,85,'Atlantic Films',6),
    ('Avatar','Children',850000,5329430,2012,110,'Rest Well',8),
    ('Kevin Hart','Comedy',300000,450000,2017,100,'Film Club',10),
     ('George Lopez','Comedy',700000,5200000,202,95,'Rocket Movies',2),
    ('Dragonball Super','Action',170000,4250000,2000,105,'MovieTime',1),
    ('Hades','Horror',275000,780000,2014,95,'MovieTime',6),
    ('Bullet Train','Comedy',155000,379000,2011,60,'MovieTime',8),
    ('The Last Will','Drama',500000,709090,2010,90,'Popcorn Films',10)
Go

---insert into ratings table
insert into ratings (movieid,website, fanrating,criticrating)
values 
    (1,'Rotten Apples',70,76),(1,'Movie Nation',77,82),(1,'Critic Corner',90,81),(1,'Movie Monster',68,74),(2,'Rotten Apples',90,71),
    (2,'Movie Nation',81,73),(2,'Critic Corner',84,78),(2,'Movie Monster',93,70),(3,'Rotten Apples',100,83),(3,'Movie Nation',92,70),
    (3,'Critic Corner',96,79),(3,'Movie Monster',90,71),(4,'Rotten Apples',72,90),(4,'Movie Nation',80,92),(4,'Critic Corner',78,87),
    (4,'Movie Monster',71,81),(5,'Rotten Apples',90,73),(5,'Movie Nation',84,80),(5,'Movie Monster',86,77),(5,'Critic Corner',87,75),
    (6, 'Rotten Apples',97,64),(7,'Movie Nation',99,53),(8,'Critic Corner',37,70),(9,'Movie Monster',53,73),(10,'Rotten Apples',35,35),
    (11,'Movie Nation',42,59),(12,'Critic Corner',76,34),(13,'Movie Monster',30,49),(14,'Rotten Apples',52,65),(15,'Movie Nation',96,72),
    (16,'Critic Corner',94,98),(17,'Movie Monster',97,60),(18,'Rotten Apples',67,44),(19,'Movie Nation',55,67),(20,'Critic Corner',88,48),
    (21,'Movie Monster',42,96),(22,'Rotten Apples',68,56),(23,'Movie Nation',34,49),(24,'Critic Corner',66,83),(25,'Movie Monster' ,39,84),
    (26,'Rotten Apples',60,66),(27,'Movie Nation',87,74),(28,'Critic Corner',95,39),(29,'Movie Monster',33,95),(30,'Rotten Apples',92,75),
    (31,'Movie Nation',52,60),(32,'Critic Corner',94,40),(33,'Movie Monster',77,81),(34,'Rotten Apples',90,65),(35,'Movie Nation',84,87),
    (36,'Critic Corner',98,81),(37,'Movie Monster',94,99),(38,'Rotten Apples',37,63),(39,'Movie Nation',62,70),(40,'Critic Corner',34,52),
    (41,'Movie Monster',47,96),(42,'Rotten Apples',60,63),(43,'Movie Nation',45,84),(44,'Critic Corner',61,45),(45,'Movie Monster' ,64,36),
    (46,'Rotten Apples',38,47),(47,'Movie Nation',41,75),(48,'Critic Corner',35,77),(49,'Movie Monster',82,50),(50,'Rotten Apples',95,47),
    (51,'Movie Nation',84,51),(52,'Critic Corner',95,33),(53,'Movie Monster',45,89),(54,'Rotten Apples',67,64),(55,'Movie Nation',82,96),
    (56,'Critic Corner',82,94),(57,'Movie Monster',96,77),(58,'Rotten Apples',88,86),(59,'Movie Nation',53,46),(60,'Critic Corner',75,90),
    (61,'Movie Monster',91,93),(62,'Rotten Apples',44,65),(63,'Movie Nation',63,47),(64,'Critic Corner',95,80),(65,'Movie Monster',88,65)
GO

---insert into moviecast
insert into moviecast (role, actorid,movietitle,prodcompany)
values
    ('Main Actor',2,'New York Lights','Olive Butter'),('Support Actor',5,'New York Lights','Olive Butter'),
    ('Main Actor',5,'Singing at Night','Apple Sauce'),('Support Actor',9,'Singing at Night','Apple Sauce'),
    ('Main Actor',4,'Dogs Asleep','Visa Direct'),('Support Actor',1,'Dogs Asleep','Visa Direct'),
    ('Main Actor',7,'Painting on the Wall','Apple Sauce'),('Support Actor',3,'Painting on the Wall','Apple Sauce'),
    ('Main Actor',4,'Knock on the Door','Visa Direct'),('Support Actor',2,'Knock on the Door','Visa Direct'),
    ('Main Actor',29,'First Kiss','Three Kings'),('Support Actor',13,'First Kiss','Three Kings'),
    ('Main Actor',9,'Adventures at Night','Three Kings'),('Support Actor',27,'Adventures at Night','Three Kings'),
    ('Main Actor',12,'Ottors','Tiger Stripe'),('Support Actor',25,'Ottors','Tiger Stripe'),
    ('Main Actor',15,'Wall of China','Tiger Stripe'),('Support Actor',27,'Wall of China','Tiger Stripe'),
    ('Main Actor',13,'Knockdown Love','Film Club'),('Support Actor',3,'Knockdown Love','Film Club'),
    ('Main Actor',7,'Young Bucks','Victory'),('Support Actor',9,'Young Bucks','Victory'),
    ('Main Actor',9,'Desert Nights','Atlantic Films'),('Support Actor',7,'Desert Nights','Atlantic Films'),
    ('Main Actor',8,'Cats Asleep','Atlantic Films'),('Support Actor',10,'Cats Asleep','Atlantic Films'),
    ('Main Actor',22,'Painting with Kat','Rest Well'),('Support Actor',15,'Painting with Kat','Rest Well'),
    ('Main Actor',21,'Knockdown Love, The Reunion','Film Club'),('Support Actor',23,'Knockdown Love, The Reunion','Film Club'),
    ('Main Actor',20,'The Journal','Rocket Movies'),('Support Actor',3,'The Journal','Rocket Movies'),
    ('Main Actor',29,'NightWing','MovieTime'),('Support Actor',9,'NightWing','MovieTime'),
    ('Main Actor',8,'The Killing','MovieTime'),('Support Actor',20,'The Killing','MovieTime'),
    ('Main Actor',7,'Bachelors Party','MovieTime'),('Support Actor',21,'Bachelors Party','MovieTime'),
    ('Main Actor',29,'The Court','Popcorn Films'),('Support Actor',22,'The Court','Popcorn Films'),
    ('Main Actor',24,'Love Hurts','Buttery PopCorn'),('Support Actor',29,'Love Hurts','Buttery PopCorn'),
    ('Main Actor',1,'Sing Bee Sing!','Buttery PopCorn'),('Support Actor',7,'Sing Bee Sing!','Buttery PopCorn'),
    ('Main Actor',28,'Baseball','Buttery PopCorn'),('Support Actor',17,'Baseball','Buttery PopCorn'),
    ('Main Actor',1,'Paris','JawDrop'),('Support Actor',21,'Paris','JawDrop'),
    ('Main Actor',12,'Love at First Arrest','JawDrop'),('Support Actor',18,'Love at First Arrest','JawDrop'),
    ('Main Actor',25,'Red Light Blue Light','Victory'),('Support Actor',28,'Red Light Blue Light','Victory'),
    ('Main Actor',29,'Space','Atlantic Films'),('Support Actor',5,'Space','Atlantic Films'),
    ('Main Actor',10,'MARS ROVERS','Atlantic Films'),('Support Actor',5,'MARS ROVERS','Atlantic Films'),
    ('Main Actor',19,'Card Fight','Rest Well'),('Support Actor',10,'Card Fight','Rest Well'),
    ('Main Actor',25,'Family Love','IndyFilms'),('Support Actor',16,'Family Love','IndyFilms'),
    ('Main Actor',17,'Divorce Again?!','IndyFilms'),('Support Actor',10,'Divorce Again?!','IndyFilms'),
    ('Main Actor',12,'DayWing','IndyFilms'),('Support Actor',13,'DayWing','IndyFilms'),
    ('Main Actor',24,'Dont Fail','IndyFilms'),('Support Actor',2,'Dont Fail','IndyFilms'),
    ('Main Actor',18,'Family Guy','MovieTime'),('Support Actor',17,'Family Guy','MovieTime'),
    ('Main Actor',1,'The Challenge','Movies for All'),('Support Actor',24,'The Challenge','Movies for All'),
    ('Main Actor',3,'Family Reunion','Movies for All'),('Support Actor',25,'Family Reunion','Movies for All'),
    ('Main Actor',3,'Santa Escape','Movies for All'),('Support Actor',22,'Santa Escape','Movies for All'),
    ('Main Actor',16,'IT Today','Happy Days'),('Support Actor',28,'IT Today','Happy Days'),
    ('Main Actor',21,'City Paint','Happy Days'),('Support Actor',11,'City Paint','Happy Days'),
    ('Main Actor',8,'Love Knocks Twice','Independent Network'),('Support Actor',10,'Love Knocks Twice','Independent Network'),
    ('Main Actor',27,'New York Christmas','Happy Days'),('Support Actor',10,'New York Christmas','Happy Days'),
    ('Main Actor',19,'American Pre-School','Independent Network'),('Support Actor',13,'American Pre-School','Independent Network'),
    ('Main Actor',25,'Elements','Atlantic Films'),('Support Actor',12,'Elements','Atlantic Films'),
    ('Main Actor',11,'Teddy','Rest Well'),('Support Actor',20,'Teddy','Rest Well'),
    ('Main Actor',14,'Supergirl','Film Club'),('Support Actor',24,'Supergirl','Film Club'),
    ('Main Actor',15,'The Hill','Rocket Movies'),('Support Actor',3,'The Hill','Rocket Movies'),
    ('Main Actor',6,'Rangers','MovieTime'),('Support Actor',5,'Rangers','MovieTime'),
    ('Main Actor',2,'Death by Sleep','Olive Butter'),('Support Actor',26,'Death by Sleep','Olive Butter'),
    ('Main Actor',16,'L0L','Independent Network'),('Support Actor',23,'L0L','Independent Network'),
    ('Main Actor',29,'The Election Campaign','Olive Butter'),('Support Actor',2,'The Election Campaign','Olive Butter'),
    ('Main Actor',21,'Love Lost','Apple Sauce'),('Support Actor',27,'Love Lost','Apple Sauce'),
    ('Main Actor',7,'1st Grade','Apple Sauce'),('Support Actor',1,'1st Grade','Apple Sauce'),
    ('Main Actor',9,'Runaway','Apple Sauce'),('Support Actor',3,'Runaway','Apple Sauce'),
    ('Main Actor',12,'Family Vacation','Visa Direct'),('Support Actor',14,'Family Vacation','Visa Direct'),
    ('Main Actor',25,'Lovers','Visa Direct'),('Support Actor',26,'Lovers','Visa Direct'),
    ('Main Actor',9,'Dora','Visa Direct'),('Support Actor',2,'Dora','Visa Direct'),
    ('Main Actor',10,'Minions','Visa Direct'),('Support Actor',21,'Minions','Visa Direct'),
    ('Main Actor',22,'Apples of the World','Atlantic Films'),('Support Actor',14,'Apples of the World','Atlantic Films'),
    ('Main Actor',15,'Avatar','Rest Well'),('Support Actor',1,'Avatar','Rest Well'),
    ('Main Actor',11,'Kevin Hart','Film Club'),('Support Actor',26,'Kevin Hart','Film Club'),
    ('Main Actor',13,'George Lopez','Rocket Movies'),('Support Actor',25,'George Lopez','Rocket Movies'),
    ('Main Actor',9,'Dragonball Super','MovieTime'),('Support Actor',29,'Dragonball Super','MovieTime'),
    ('Main Actor',25,'Hades','MovieTime'),('Support Actor',7,'Hades','MovieTime'),
    ('Main Actor',12,'Bullet Train','MovieTime'),('Support Actor',10,'Bullet Train','MovieTime'),
    ('Main Actor',9,'The Last Will','Popcorn Films'),('Support Actor',26,'The Last Will','Popcorn Films')
GO


---insert into filmlocations
insert into filmlocations (locationtype, movieid, movietitle,rentalrate,date_in,date_out)
values 
    ('Beach',3,(select movietitle from movies where movieid=3),20000,'2012-04-06','2012-06-01'),
    ('Coffee Shop',2,(select movietitle from movies where movieid=2),15000,'2018-04-06','2018-05-02'),
    ('Park',5,(select movietitle from movies where movieid=5),10000,'2008-12-04','2008-12-30'),
    ('Coffee Shop',1,(select movietitle from movies where movieid=1),15000,'2020-08-27','2020-09-01'),
    ('Park',4,(select movietitle from movies where movieid=4),15000,'2010-04-29','2010-05-16'),
    ('Coffee Shop',20,(select movietitle from movies where movieid=20),17500,'1998-07-16','1998-10-05'),
    ('Studio',42,	(select movietitle from movies where movieid=42),13000,'2000-01-17','2000-02-15'),
    ('Park',62,	(select movietitle from movies where movieid=62),13000,'1999-02-14','1999-04-10'),
    ('Apartment',32,	(select movietitle from movies where movieid=32),12000,'1999-11-08	','1999-12-06'),
    ('Loft',26,	(select movietitle from movies where movieid=26),112000,'2000-04-17','2000-12-14'),
    ('City Streets',45,	(select movietitle from movies where movieid=45),12000,'2001-09-05	','2001-10-16'),
    ('Amusement Park',33,	(select movietitle from movies where movieid=33),12000,'2002-06-27',	'2002-12-18'),
    ('Wedding Hall',53,	(select movietitle from movies where movieid=53),14000,'2002-07-16','2002-09-16'),
    ('Dojo',39,	(select movietitle from movies where movieid=39),12000,'2007-07-17','2007-11-06'),
    ('Skyscrapers',51,(select movietitle from movies where movieid=51),19000,'2007-09-03','2007-11-28'),
    ('Cruise Line',10,(select movietitle from movies where movieid=10),12000,'2008-05-04','2008-08-11'),
    ('Barren Field',17,(select movietitle from movies where movieid=17),41000,'2008-06-16','2008-08-24'),
    ('Restaurant 1',30,(select movietitle from movies where movieid=30),17500,'2008-04-30','2008-11-08'),
    ('Restaurant 2',44,(select movietitle from movies where movieid=44),19200,'2008-10-29','2008-12-06'),
    ('Restaurant 3',65,(select movietitle from movies where movieid=65),18700,'2008-09-29','2008-12-03'),
    ('Prison',9,(select movietitle from movies where movieid=9),15000,'2009-01-19','2009-03-21'),
    ('Bedroom',24,(select movietitle from movies where movieid=24),12000,'2009-10-31','2009-12-11'),
    ('Animation Studio',34,(select movietitle from movies where movieid=34),11000,'2009-08-08','2009-10-20'),
    ('Custom Themed Studio',49,(select movietitle from movies where movieid=49),15000,'2009-04-11','2009-07-13'),
    ('Studio',64,(select movietitle from movies where movieid=64),12000,'2009-09-13','2010-02-10'),
    ('Park',16,	(select movietitle from movies where movieid=16),11000,'2010-10-13','2010-11-26'),
    ('Apartment',22,(select movietitle from movies where movieid=22),19200,'2010-10-30','2011-01-30'),
    ('Loft',59,(select movietitle from movies where movieid=59),11200,'2010-03-02','2010-05-31'),
    ('City Streets',15,(select movietitle from movies where movieid=15),16000,'2011-07-11','2011-08-29'),
    ('Amusement Park',58,(select movietitle from movies where movieid=58),11500,'2011-04-10','2011-5-24'),
    ('Wedding Hall',8,(select movietitle from movies where movieid=8),14000,'2012-03-05','2012-04-19'),
    ('Dojo',14,(select movietitle from movies where movieid=14),12000,'2012-02-16','2012-10-11'),
    ('Skyscrapers',18,(select movietitle from movies where movieid=18),19000,'2012-03-31','2012-10-11'),
    ('Cruise Line',48,(select movietitle from movies where movieid=48),12000,'2012-02-13','2012-12-07'),
    ('Barren Field',63,(select movietitle from movies where movieid=63),11100,'2012-01-08','2012-02-13'),
    ('Restaurant 1',13,(select movietitle from movies where movieid=13),17500,'2013-08-16','2013-10-05'),
    ('Restaurant 2',25,(select movietitle from movies where movieid=25),19200,'2013-07-30','2013-11-18'),
    ('Restaurant 3',52,(select movietitle from movies where movieid=52),18700,'2013-09-24','2013-11-18'),
    ('Prison',12,(select movietitle from movies where movieid=12),15000,'2014-01-15','2014-03-25'),
    ('Bedroom',31,(select movietitle from movies where movieid=31),12000,'2014-03-24','2015-01-20'),
    ('Animation Studio',35,(select movietitle from movies where movieid=35),11800,'2014-06-26','2014-09-16'),
    ('Custom Themed Studio',36,(select movietitle from movies where movieid=36),21500,'2015-08-24','2015-10-20'),
    ('Studio',60,(select movietitle from movies where movieid=60),12000,'2015-07-25','2015-08-21'),
    ('Park',29,(select movietitle from movies where movieid=29),11000,'2016-04-28','2016-09-19'),
    ('Apartment',38,(select movietitle from movies where movieid=38),19200,'2016-02-20','2016-03-13'),
    ('Loft',50,(select movietitle from movies where movieid=50),12000,'2016-05-09','2017-01-19'),
    ('City Streets',19,(select movietitle from movies where movieid=19),16000,'2018-06-26','2018-10-15'),
    ('Amusement Park',40,(select movietitle from movies where movieid=40),11500,	'2018-10-18','2018-12-31'),
    ('Wedding Hall',61,(select movietitle from movies where movieid=61),14000,'2018-05-28','2018-09-21'),
    ('Dojo',7,(select movietitle from movies where movieid=7),12000,'2018-02-02','2018-07-21'),
    ('Skyscrapers',21,(select movietitle from movies where movieid=21),19000,'2018-02-28	','2018-10-19'),
    ('Cruise Line',27,(select movietitle from movies where movieid=27),12000,'2019-07-01','2019-08-17'),
    ('Beach',37,(select movietitle from movies where movieid=37),11000,'2019-04-09','2019-09-16'),
    ('Coffee Shop',47,(select movietitle from movies where movieid=47),17500,'2019-03-31','2019-11-02'),
    ('Studio',28,(select movietitle from movies where movieid=28),19200,'2019-02-13','2019-06-26'),
    ('Park',43,	(select movietitle from movies where movieid=43),18700,'2020-02-26','2020-04-28'),
    ('Apartment',56,(select movietitle from movies where movieid=56),15000,'2020-07-12','2020-12-12'),
    ('Loft',57,(select movietitle from movies where movieid=57),12000,'2020-01-19','2020-03-24'),
    ('City Streets',6,(select movietitle from movies where movieid=6),11800,'2020-03-08','2020-07-24'),
    ('Amusement Park',23,(select movietitle from movies where movieid=23),11500,'2021-07-13','2021-08-13'),
    ('Wedding Hall',41,(select movietitle from movies where movieid=41),14000,'2021-07-25','2021-09-26'),
    ('Dojo',46,(select movietitle from movies where movieid=46),12000,'2021-06-30','2021-09-04'),
    ('Skyscrapers',54,(select movietitle from movies where movieid=54),91000,'2021-02-17','2021-07-06'),
    ('Cruise Line',55,(select movietitle from movies where movieid=55),14000,'2021-06-16','2021-08-17')
GO
------------------------------------------------------------------------------------------------------------
---select each table
select * from filmlocations
select * from moviecast 
select * from ratings 
select * from locations
select * from movies 
select * from prodcompany
select * from genres
select * from persons
select * from role
GO

--- update persons rate
CREATE PROCEDURE p_upsert_personsrate(
       @personid int,
       @rate money)
  AS 
  if exists (select * from persons where personid=@personid)
    update persons 
        set rate = @rate 
        where personid = @personid
  else 
    insert persons(personid, rate)
    values(@personid, @rate)
GO


select * from persons
go
select * from persons exec p_upsert_personsrate @personid=2, @rate=80000
GO
select * from persons
go



--- update filmlocations rental rate


CREATE PROCEDURE p_upsert_filmlocationrentalrate(
       @locationid int,
       @rentalrate money
)
  AS 
  if exists (select * from filmlocations where locationid=@locationid )
    update filmlocations 
        set rentalrate = @rentalrate 
        where locationid = @locationid 
  else 
    insert filmlocations(locationid,rentalrate)
    values(@locationid, @rentalrate)
GO

select * from filmlocations
select * from filmlocations exec p_upsert_filmlocationrentalrate @locationid=1, @rentalrate=30000
GO
select * from filmlocations
GO


--- update movie fan ratings



CREATE PROCEDURE p_upsert_fanrating(
       @ratingid int,
       @movieid int,
       @fanrating int
)
  AS 
  if exists (select * from ratings where ratingid=@ratingid and movieid = @movieid )
    update ratings 
        set fanrating = @fanrating
        where ratingid = @ratingid and movieid = @movieid 
  else 
    insert ratings(ratingid,movieid, fanrating)
    values(@ratingid,@movieid, @fanrating)
GO

select * from ratings
select * from ratings exec p_upsert_fanrating @ratingid=3, @movieid=1, @fanrating=88
GO
select * from ratings
GO

--- add/ new movie rating update movie Critic ratings 
CREATE PROCEDURE p_upsert_criticrating(
       @ratingid int,
       @movieid int,
       @criticrating int
)
  AS 
  if exists (select * from ratings where ratingid=@ratingid and movieid = @movieid )
    update ratings 
        set criticrating = @criticrating
        where ratingid = @ratingid and movieid = @movieid 
  else 
    insert into ratings(ratingid, movieid, criticrating)
    values(@ratingid, @movieid, @criticrating)
    GO
    
GO


select * from ratings
go
select * from ratings exec p_upsert_criticrating @ratingid=3, @movieid=1, @criticrating=80
GO
select * from ratings
GO

---------------------------------------------------------------------------------------------------------------
--- search for rental rates

CREATE proc p_search_flr
( @rentalrate money)
as BEGIN
select 
      [locationtype]
      ,[movieid]
      ,[movietitle]
      ,[rentalrate]
      , [date_in]
      ,[date_out]  
from filmlocations
where  rentalrate = @rentalrate or rentalrate < @rentalrate 
END
GO

EXEC p_search_flr  40000
GO
---Search for persons 

CREATE proc p_search_person
(@name varchar(MAX))
as BEGIN
select *
from persons
where firstname like @name+'%' or lastname like @name+'%' 
or gender like @name+'%' 
END
GO

EXEC p_search_person 'j'
GO


--- search for movies by movie title, release year, genre, or production company

CREATE proc p_search_movies
(@name varchar(MAX))
as BEGIN
select *
from movies
where movietitle like @name+'%' or genre like @name+'%' 
or yearrelease like @name+'%' or prodcompany like @name+'%' 
END
GO

EXEC p_search_movies 2020
GO


----------------------------------------------
---BUDGET VIEW

create view budget as 

with moviebudget as (
select distinct mc.movietitle, m.budget,
sum(p.rate) over (partition by mc.movietitle) as actorcost,
d.rate as directorcost,
fl.rentalrate  as locationcost
from moviecast mc , movies m , persons p, filmlocations fl, persons d 
where mc.movietitle = m.movietitle 
and p.personid = mc.actorid  
and d.personid = m.director
and fl.movieid=m.movieid 
group by mc.movietitle , m.budget , mc.actorid, p.rate , d.rate , fl.rentalrate
)
select distinct  mb.movietitle, m.genre, actorcost, directorcost, locationcost, mb.budget as initial_budget,
sum(actorcost + directorcost + locationcost) over (partition by m.movietitle, mb.movietitle) as actual_budget, 
m.revenue as theater_revenue,
m.revenue - sum(actorcost + directorcost + locationcost) over (partition by m.movietitle, mb.movietitle) total_revenue
from moviebudget mb
left join movies m on mb.movietitle = m.movietitle 

GO 



--Budget Classification
select movietitle, initial_budget, actual_budget,
(case
    when actual_budget > 0 then 'Under Budget'
    when actual_budget < 0 then 'Over Budget'
    else 'On Budget Target'
    end) 'Budget Classification'
from budget
GO

--- Budgetinfo View 
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
go

---highest rated movie
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
GO

--location rental rates total
select locationtype, sum(rentalrate) as total_rentalrate
from filmlocations
group by locationtype
order by total_rentalrate desc ;
GO


---ratings by website
select r.website, avg(r.fanrating) as fanrating, avg(r.criticrating) as criticrating
from ratings r
group by r.website
GO


-- update movie table

CREATE PROCEDURE p_upsert_updatemoviestable
    (@movieid int, 
    @revenue money,
    @yearrelease char(4),
    @runtime int) as 
if exists (select * from movies where movieid=@movieid)
BEGIN 
    UPDATE movies 
    set revenue = @revenue, 
    yearrelease = @yearrelease, 
    runtime = @runtime
    where movieid = @movieid
    and revenue is NULL 
    and yearrelease is null 
    and runtime is null
END 

go

-- person rates total
select sum(rate) as RateTotal from persons
go


-- film location total costs per movie
select movietitle, sum(rentalrate) as total_rentalrate
    from filmlocations
    group by movietitle
    order by total_rentalrate
GO

/*
-- view sum of rental rate per location
drop view if exists totalRentalRatePerLocation
go
create or alter view totalRentalRatePerLocation as 
    select locationid as location, sum(rate) as totalRentalRatePerLocation
        from filmlocations
    order by totalRentalRatePerLocation
*/





--- which actors have also directed?

select distinct p.personid, p.firstname, p.lastname, m.director
from moviecast mc
join persons p on mc.actorid=p.personid
join movies m on p.personid=m.director
order by personid
go 

--- which actors have also directed and for which movies ?
select distinct p.personid, p.firstname, p.lastname, mc.movietitle, mc.prodcompany, m.director
from moviecast mc
join persons p on mc.actorid=p.personid
join movies m on p.personid=m.director
order by personid
go 

--location days
create view filmschedule as(
select locationtype, movietitle, rentalrate, date_in, date_out, datediff(day, date_in, date_out) as num_of_days 
from filmlocations )
go 

select * from filmschedule 

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
GO
---which is the most popular genre for fans based on fan ratings?

select distinct m.genre,
avg(fanrating) over (partition by m.genre) as avg_fanrating,
avg(f.rentalrate) over (partition by m.genre) as avg_location_rentalrate,
avg(f.num_of_days) over (partition by m.genre) as avg_filming_days,
avg(runtime) over (partition by m.genre) as avg_runtime,
avg(p.rate) over (partition by m.genre) as avg_director_cost
from movies m, ratings r , filmschedule f, persons p
where m.movieid = r.movieid 
and m.movietitle = f.movietitle
and p.personid=m.director
group by m.genre, r.fanrating, f.rentalrate, f.num_of_days, m.runtime, p.rate 
ORDER by avg_fanrating DESC
GO


--which movies take the longest to film?
select movietitle,
sum(rentalrate) over (partition by movietitle) as total_location_rentalrate,
sum(num_of_days) over (partition by movietitle) as total_filming_days
from filmschedule 
order by total_filming_days desc
GO

--average cost and average filming days per category
select distinct m.genre,
avg(f.rentalrate) over (partition by m.genre) as total_location_rentalrate,
avg(f.num_of_days) over (partition by m.genre) as total_filming_days
from filmschedule f, movies m
where m.movietitle = f.movietitle
order by  total_filming_days desc
GO

--- how many movies were released per year?
select yearrelease , count (movietitle) 
from movies 
group by yearrelease
go 

--number of movies by year
select  m.yearrelease,
count(m.yearrelease) movies_per_year
from movies m
group by m.yearrelease
GO

--------------------------------------------------------------------------------------------
select * from filmlocations where movietitle = '1st Grade'
select * from budget
order by total_revenue 
GO


select m.movietitle, r.website, r.fanrating, r.criticrating
from movies m, ratings r 
where m.movieid = r.movieid 
GO

select r.website, avg(r.fanrating) as fanrating, avg(r.criticrating) as criticrating
from ratings r 
group by r.website
GO

select sum(rentalrate) over (partition by movietitle) from filmlocations  where movietitle = 'Adventures at Night'
select * from budget 
GO

select distinct m.movietitle,
 sum(p.rate) over (partition by m.movietitle) , s.director, d.rate
from moviecast m, persons p, movies s, persons d
where p.personid = m.actorid 
and d.personid = s.director
and s.movietitle = m.movietitle 
group by m.movietitle, s.director, d.rate, p.rate 
GO
