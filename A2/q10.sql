-- Rainmakers

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q10 cascade;

create table q10(
	driver_id INTEGER,
	month CHAR(2),
	mileage_2014 FLOAT,
	billings_2014 FLOAT,
	mileage_2015 FLOAT,
	billings_2015 FLOAT,
	billings_increase FLOAT,
	mileage_increase FLOAT
);


-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Details2014 CASCADE;
DROP VIEW IF EXISTS TripDistances CASCADE;
DROP VIEW IF EXISTS Details2015 CASCADE;


-- Finds the total distance of every requested trip
CREATE VIEW TripDistances AS
SELECT Request.request_id, src.location <@> dest.location as distance
FROM Request JOIN Place src ON Request.source=src.name
	JOIN Place dest on Request.destination=dest.name;


-- Finds the total distance travelled, and amount billed
-- by each driver for each month of 2014
CREATE VIEW Details2014 AS
SELECT driver_id, CAST(LPAD(EXTRACT(month from 
request.datetime)::text, 2, '0') as CHAR(2)) as month, 
sum(TripDistances.distance) as mileage_2014, 
sum(Billed.amount) as billings_2014
FROM Dispatch JOIN Request ON Dispatch.request_id=Request.request_id
	JOIN Dropoff ON Dispatch.request_id=Dropoff.request_id
	JOIN TripDistances on Dropoff.request_id=TripDistances.request_id
	JOIN Billed on Dropoff.request_id=Billed.request_id
WHERE request.datetime>='2014-01-01 00:00' AND 
	request.datetime<'2015-01-01 00:00' 
GROUP BY driver_id,month;


-- Finds the total distance travelled, and amount billed
-- by each driver for each month of 2015
CREATE VIEW Details2015 AS
SELECT driver_id, CAST(LPAD(EXTRACT(month from 
request.datetime)::text, 2, '0') as CHAR(2)) as month, 
sum(TripDistances.distance) as mileage_2015, 
sum(Billed.amount) as billings_2015
FROM Dispatch JOIN Request ON Dispatch.request_id=Request.request_id
	JOIN Dropoff ON Dispatch.request_id=Dropoff.request_id
	JOIN TripDistances on Dropoff.request_id=TripDistances.request_id
	JOIN Billed on Dropoff.request_id=Billed.request_id
WHERE request.datetime>='2015-01-01 00:00' 
	AND request.datetime<'2016-01-01 00:00' 
GROUP BY driver_id,month;



-- Your query that answers the question goes below the "insert into" line:
insert into q10
SELECT driver_id,month, mileage_2014, billings_2014, mileage_2015, 
billings_2015, billings_2015-billings_2014 as billings_increase, 
mileage_2015-mileage_2014 as mileage_increase
FROM Details2014 NATURAL JOIN Details2015;
