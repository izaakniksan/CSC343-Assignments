-- Scratching backs?

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
drop table if exists q8 cascade;

create table q8(
	client_id INTEGER,
	reciprocals INTEGER,
	difference FLOAT
);


-- Get the relevant info from tables needed
DROP VIEW IF EXISTS reciprocalTrips CASCADE;
CREATE VIEW reciprocalTrips AS
Select Dispatch.request_id, dispatch.driver_id, 
driverrating.rating as driver_rating,
	request.client_id, clientrating.rating as client_Rating
FROM Dispatch JOIN Request ON Dispatch.request_id = request.request_id 
	JOIN ClientRating ON ClientRating.request_id = request.request_id
	JOIN DriverRating ON DriverRating.request_id = request.request_id;
;



-- Calculates the info desired in the question
insert into q8
Select client_id, count(request_id) as reciprocals, 
avg(driver_rating - client_rating) as difference
FROM reciprocalTrips
GROUP BY client_id;
