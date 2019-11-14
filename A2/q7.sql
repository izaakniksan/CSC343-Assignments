-- Ratings histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q7 cascade;

create table q7(
	driver_id INTEGER,
	r5 INTEGER,
	r4 INTEGER,
	r3 INTEGER,
	r2 INTEGER,
	r1 INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
-- Define views for your intermediate steps here:

--Every drivers rating and amount they were rated that 
DROP VIEW IF EXISTS ratings CASCADE;
CREATE VIEW ratings AS
Select rating, driver_id, count(rating) as amount
FROM Dispatch NATURAL JOIN DriverRating
GROUP BY driver_id, rating;

-- Creates all possible driver ratings
DROP VIEW IF EXISTS allDrivers CASCADE;
CREATE VIEW allDrivers AS
select driver_id, 0 as r1, 0 as r2, 0 as r3, 0 as r4, 0 as r5
FROM (
Select driver_id from Driver) as asd
;

-- Adds the rating amount under the specific rating value column (r5, r4, ...)
CREATE VIEW allDriverRatings AS
select driver_id, CASE WHEN rating = 1 THEN amount END as r1,
 CASE WHEN rating = 2 THEN amount END as r2,
 CASE WHEN rating = 3 THEN amount END as r3,
 CASE WHEN rating = 4 THEN amount END as r4,
 CASE WHEN rating = 5 THEN amount END as r5
FROM Ratings
;

-- Your query that answers the question goes below the "insert into" line:
insert into q7
Select driver_id, CASE WHEN sum(r5) <> 0 THEN sum(r5) ELSE NULL END as r5,
CASE WHEN sum(r4) <> 0 THEN sum(r4) ELSE NULL END as r4,
CASE WHEN sum(r3) <> 0 THEN sum(r3) ELSE NULL END as r3,
CASE WHEN sum(r2) <> 0 THEN sum(r2) ELSE NULL END as r2,
CASE WHEN sum(r1) <> 0 THEN sum(r1) ELSE NULL END as r1
from(
  Select * from allDriverRatings UNION Select * from allDrivers) as 
combinedRatings
Group by driver_id
Order by driver_id asc;
