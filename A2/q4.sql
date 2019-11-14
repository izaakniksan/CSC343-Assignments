-- Do drivers improve?

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q4 cascade;

create table q4(
	type VARCHAR(9),
	number INTEGER,
	early FLOAT,
	late FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS driverInfo CASCADE;
DROP VIEW IF EXISTS atLeastTen CASCADE;
DROP VIEW IF EXISTS earlyAverage CASCADE;
DROP VIEW IF EXISTS firstDay CASCADE;
DROP VIEW IF EXISTS firstFive CASCADE;
DROP VIEW IF EXISTS afterFirstFive CASCADE;


-- Finds driver_id, date, datetime, rating, and request_id 
-- of every completed trip
CREATE VIEW driverInfo AS
SELECT driver.driver_id, date(request.datetime) ridedate, 
request.datetime datetime, rating, dispatch.request_id, 
CASE WHEN driver.trained = true THEN 'trained' ELSE 'untrained' END as trained
FROM driver JOIN Dispatch ON  driver.driver_id=Dispatch.driver_id
	    JOIN Request ON Dispatch.request_id=Request.request_id
	    JOIN Dropoff ON Dispatch.request_id=Dropoff.request_id
	    LEFT JOIN DriverRating 
		ON Dispatch.request_id=DriverRating.request_id;

-- Drivers with at least 10 different ride days
CREATE VIEW atLeastTen AS
SELECT driver_id, min(rideDate) as firstDate
FROM driverInfo 
GROUP BY driver_id
HAVING count(distinct ridedate)>=10;

-- Finds rides in the first 5 days for each driver with >= 10 
-- different ride days
CREATE VIEW firstFive AS
SELECT a.driver_id,  avg(rating) as early_average, a.trained
FROM driverInfo a JOIN atLeastTen ON a.driver_id=atLeastTen.driver_id
WHERE a.rideDate<atLeastTen.firstDate + 5  -- Postgresql understands this +5
GROUP BY a.driver_id, a.trained
;


-- Finds rides AFTER the first 5 days for each driver with >= 10 
-- different ride days
CREATE VIEW afterFirstFive AS
SELECT a.driver_id,  avg(rating) as late_average, a.trained
FROM driverInfo a JOIN atLeastTen ON a.driver_id=atLeastTen.driver_id
WHERE a.rideDate>=atLeastTen.firstDate + 5  -- Postgresql understands this +5
GROUP BY a.driver_id, a.trained
;

DROP VIEW IF EXISTS temp CASCADE;
CREATE VIEW temp AS
Select type, NULL as number, NULL as early, NULL as late
FROM  (select 'trained' as type union all select 'untrained' as type) as a;

-- Your query that answers the question goes below the "insert into" line:
insert into q4
Select firstFive.trained as type, count(distinct firstFive.driver_id) as number, 
avg(early_average) as early, avg(late_average) as late
FROM firstFive JOIN afterfirstFive ON firstFive.driver_id = afterfirstFive.driver_id
GROUP BY firstFive.trained
;


Select firstFive.trained as type, count(distinct firstFive.driver_id) as number, 
avg(early_average) as early, avg(late_average) as late
FROM firstFive JOIN afterfirstFive ON firstFive.driver_id = afterfirstFive.driver_id
	RIGHT JOIN  (select 'trained' as type union all select 'untrained' as type) as a on firstFive.trained=a.type
GROUP BY firstFive.trained
;




