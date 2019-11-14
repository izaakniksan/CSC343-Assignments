-- Bigger and smaller spenders

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q5 cascade;

create table q5(
	client_id INTEGER,
	months VARCHAR(7), 
	total FLOAT,
	comparison VARCHAR(30)  
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
-- Define views for your intermediate steps here:

-- Every request, amount paid, and formatted month
DROP VIEW IF EXISTS formatdate CASCADE;
Create View formatdate AS
Select request_id, amount, client_id, 
cast(Extract(year from datetime) as varchar)
	|| ' ' || cast(Extract(month from datetime) as varchar) as yearmonth
FROM Billed NATURAL JOIN Request;

-- Every customers spending per month
DROP VIEW IF EXISTS allSpendings CASCADE;

Create View allSpendings AS
Select client_id, yearmonth, sum(amount)as total
FROM formatDate
GROUP BY client_id, yearmonth;

-- Every possible combination of Client, month that had a trip
DROP VIEW IF EXISTS ALLPOSSIBLE CASCADE;

Create View ALLPOSSIBLE AS
Select client_id, yearmonth, 0 as total
FROM (
	Select yearmonth from formatdate) as AllDates,
	 (
		Select client_id From Client) as AllClients;

-- Calculates the average spending each month
DROP VIEW IF EXISTS monthAverages CASCADE;

Create View monthAverages AS
Select yearmonth, avg(amount) as average
FROM formatdate
GROUP BY yearmonth;

-- Your query that answers the question goes below the "insert into" line:
insert into q5
Select client_id, yearmonth as month, sum(total) as total,
 	CASE WHEN sum(total) < average THEN 'below' ELSE 'at or above' END
FROM (
	Select * from allSpendings UNION Select * from ALLPOSSIBLE ) 
	as combinedtotals
	 NATURAL JOIN monthAverages
GROUP BY client_id, yearmonth, average
;
