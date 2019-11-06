-- Months

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q1 cascade;

create table q1(
    client_id INTEGER,
    email VARCHAR(30),
    months INTEGER
);

DROP VIEW IF EXISTS Rides CASCADE;
DROP VIEW IF EXISTS UniqueMonths CASCADE;


-- These are the rides that were completed. The datetimes used here are 
-- those of the request, not the drop off
CREATE VIEW Rides AS
SELECT Dropoff.request_id request_id, Request.datetime datetime, client_id
FROM Dropoff JOIN Request on Dropoff.request_id=Request.request_id;

-- These are the unique months that a given client has had ride(s) in
CREATE VIEW UniqueMonths AS
SELECT DISTINCT cast(extract(year from datetime) as varchar(7)) ||  
cast(extract(month from datetime) as varchar(7)) as month, client_id
FROM Rides ;

insert into q1
SELECT Client.client_id,email,count(month)
FROM Client  JOIN UniqueMonths ON Client.client_id=UniqueMonths.client_id
GROUP BY Client.client_id;
