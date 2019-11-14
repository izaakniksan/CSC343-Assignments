-- Consistent raters

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q9 cascade;

create table q9(
	client_id INTEGER,
	email VARCHAR(30)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
-- Define views for your intermediate steps here:

-- Every ride in which the client has rated
DROP VIEW IF EXISTS allratedrides CASCADE;
CREATE VIEW allratedrides AS
SELECT client_id, driver_id, rating
FROM ClientRating NATURAL JOIN Request JOIN Dispatch
	ON dispatch.request_id = request.request_id;

-- All possible combinations of client, driver rides
DROP VIEW IF EXISTS allcomb CASCADE;
CREATE VIEW allcomb AS
Select client_id, driver_id
FROM Request JOIN Dispatch ON dispatch.request_id = request.request_id;

-- These guys didn't rate all of their rides
DROP VIEW IF EXISTS failures CASCADE;
CREATE VIEW failures AS
Select allcomb.client_id
from allcomb LEFT JOIN allratedrides ON
 	allcomb.driver_id = allratedrides.driver_id
 	AND allcomb.client_id = allratedrides.client_id
Where rating IS NULL
;

-- Your query that answers the question goes below the "insert into" line:
insert into q9
Select success.client_id, email
FROM (select client_id from allratedrides EXCEPT
	 Select client_id from failures) as success
NATURAL JOIN Client
;
