-- Frequent riders

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q6 cascade;

create table q6(
	client_id INTEGER,
	year CHAR(4),
	rides INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS completed_trips CASCADE;


-- Finds the number of completed trips for each year for each client
CREATE VIEW completed_trips AS
SELECT request.client_id, EXTRACT(year from request.datetime) rideyear, 
count(*) numtrips
FROM request JOIN dropoff ON  request.request_id=dropoff.request_id
GROUP BY request.client_id,rideyear;


-- Your query that answers the question goes below the "insert into" line:

-- Answer to the question is below. Top 3 are found by ensuring that the
-- number of rides is greater than or equal to all 3 of the top number
-- of rides for that year. Lowest 3 are found similarly.
insert into q6
SELECT a.client_id, a.rideyear as year, a.numtrips as rides
FROM completed_trips a
WHERE a.numtrips >= ANY (
	SELECT b.numtrips
	FROM completed_trips b
	WHERE a.rideyear=b.rideyear
	ORDER BY numtrips desc
	LIMIT 3)
	OR
	a.numtrips <= ANY (
	SELECT b.numtrips
	FROM completed_trips b
	WHERE a.rideyear=b.rideyear
	ORDER BY numtrips
	LIMIT 3);
