-- Lure them back

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q2 cascade;

create table q2(
    client_id INTEGER,
    name VARCHAR(41),
    email VARCHAR(30),
    billed FLOAT,
    decline INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Rides CASCADE;
DROP VIEW IF EXISTS PreviousRider CASCADE;
DROP VIEW IF EXISTS FewIn2014 CASCADE;
DROP VIEW IF EXISTS FewerIn2015 CASCADE;


-- These are the rides that were completed. The datetimes used here are 
-- those of the request, not the drop off
CREATE VIEW Rides AS
SELECT Dropoff.request_id request_id, Request.datetime datetime, client_id,
 amount
FROM Dropoff JOIN Request on Dropoff.request_id=Request.request_id
	     JOIN Billed on Dropoff.request_id=Billed.request_id;

-- Riders who had rides before 2014 costing at least $500 in total
CREATE VIEW PreviousRider AS
SELECT client_id, sum(amount) billed
FROM Rides
WHERE datetime<'2014-01-01 00:00'
GROUP BY client_id
HAVING sum(amount)>=500;

-- Riders who had between 1 and 10 rides in 2014. NOTE: Ambiguity 
-- in question, we assume 1 and 10 are included here.
CREATE VIEW FewIn2014 AS
SELECT client_id
FROM Rides
WHERE datetime>='2014-01-01 00:00' AND datetime<'2015-01-01 00:00' 
GROUP BY client_id
HAVING count(request_id)>=1 and count(request_id)<=10;


-- Riders who had fewer rides in 2015 than in 2014
-- Here, we remove tuples where the number of rides
-- in 2015 was larger than in 2014.
CREATE VIEW FewerIn2015 AS
SELECT X1.client_id client_id,
 	-- Below, this coalesce finds the decline in 
	-- rides from 2014 to 2015. If there were no
	-- rides in 2015 (NULL subquery), the deline
	-- is just equal to the number of rides in 2014.
	COALESCE((SELECT count(request_id) 
	FROM Rides AS X2
	WHERE datetime>='2014-01-01 00:00' AND 
	  datetime<'2015-01-01 00:00' AND X2.client_id=X1.client_id 
	GROUP BY client_id) - (SELECT count(request_id) 
	FROM Rides AS X2
	WHERE datetime>='2015-01-01 00:00' AND 
	  datetime<'2016-01-01 00:00' AND X2.client_id=X1.client_id 
	GROUP BY client_id), (SELECT count(request_id) 
	FROM Rides AS X2
	WHERE datetime>='2014-01-01 00:00' AND 
	  datetime<'2015-01-01 00:00' AND X2.client_id=X1.client_id 
	GROUP BY client_id))  as decline

FROM Rides AS X1
WHERE (SELECT count(request_id) 
	FROM Rides AS X2
	WHERE datetime>='2014-01-01 00:00' AND datetime<'2015-01-01 00:00' 
		AND X2.client_id=X1.client_id 
	GROUP BY client_id)
      >
      (SELECT count(request_id) 
	FROM Rides AS X2
	WHERE datetime>='2015-01-01 00:00' AND datetime<'2016-01-01 00:00' 
		AND X2.client_id=X1.client_id 
	GROUP BY client_id)
	OR
	(SELECT count(request_id) 
	FROM Rides AS X2
	WHERE datetime>='2015-01-01 00:00' AND datetime<'2016-01-01 00:00' 
		AND X2.client_id=X1.client_id 
	GROUP BY client_id) IS NULL
GROUP BY client_id;


-- Your query that answers the question goes below the "insert into" line:
insert into q2
SELECT client_id, firstname || ' ' || surname as name, 
COALESCE(email,'unknown') email, billed, decline
FROM FewerIn2015 NATURAL JOIN FewIn2014 NATURAL JOIN 
PreviousRider NATURAL JOIN Client;
