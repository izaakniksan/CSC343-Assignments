SET SEARCH_PATH TO uber, public;
drop table if exists q3 cascade;

create table q3(
    driver_id INTEGER,
    start DATE,
    driving INTERVAL,
    breaks INTERVAL
);

-- All drivers and their trips done at each day.
DROP VIEW IF EXISTS Sorted CASCADE;
CREATE VIEW Sorted AS
SELECT driver_id, date(pickup.datetime) as day, Pickup.datetime as picktime,
 Dropoff.datetime as droptime
FROM Dispatch, Pickup, Dropoff
WHERE Pickup.request_id = Dropoff.request_id
AND Dispatch.request_id = Pickup.request_id
AND Dropoff.datetime IS NOT NULL;

-- DRIVERS WHO HAVE HAD DAYS WITH 12+ hours worked on a single day
DROP VIEW IF EXISTS Duration CASCADE;
CREATE VIEW Duration AS
SELECT driver_id, day, sum(droptime - picktime) as dur
FROM Sorted
GROUP BY driver_id, day
HAVING sum(droptime - picktime) >= '12:00:00' ;

-- CREATES TABLE THAT CONTAINS EACH DRIVER'S BREAK TIME INBETWEEN EACH JOB
DROP VIEW IF EXISTS Breaks CASCADE;
CREATE VIEW Breaks AS
Select s1.driver_id, s1.day, s1.droptime, Available.datetime, 
s2.picktime, (s2.picktime - s1.droptime) as break
FROM Sorted as s1, Available, Sorted as s2
WHERE s1.driver_id = Available.driver_id
AND s1.driver_id = s2.driver_id
AND s1.day = DATE(Available.datetime)
AND s1.day = s2.day
AND Available.datetime > s1.droptime
AND Available.datetime < s2.picktime;

-- SUMS TOTAL BREAK TIME FOR EACH DRIVER EACH DAY
DROP VIEW IF EXISTS violaters CASCADE;
CREATE VIEW Violaters AS
Select *
FROM Duration as morethan12 NATURAL JOIN (
	Select d1.driver_id, d1.day, sum(d1.break) as breaktime
	FROM Breaks as d1, Breaks as d2
	Where d1.datetime = d2.datetime
	AND d1.driver_id = d2.driver_id
	AND d1.break < d2.break
	GROUP BY d1.driver_id, d1.day
	HAVING sum(d1.break) < '00:15:00') as sumbreak
;

-- All the days who have duration of 12+ hours in a single trip edge cases
-- NEED TO HANDLE DUPLICATE DAYS BETWEEN THE TWO
CREATE VIEW edge AS
Select distinct durat.driver_id, durat.day, durat.dur, 
CAST('00:00:00' AS interval) as breaktime
FROM Duration as durat,
	(Select s1.driver_id, s1.day
	From sorted as s1, sorted as s2
	WHERE s1.driver_id = s2.driver_id
	AND s1.picktime = s2.picktime
	AND s1.droptime = s2.droptime) as samedays
WHERE durat.day = samedays.day
AND durat.driver_id = samedays.driver_id
;

--COMBINES INFORMATION TOGETHER FROM EDGE CASES AND THE LAW BREAKERS
DROP VIEW IF EXISTS combine CASCADE;
CREATE VIEW combine AS
Select driver_id, day, dur, sum(breaktime) as totalbreak 
FROM (Select * from Violaters UNION Select * from edge) as combine
GROUP BY driver_id, day, dur
;

-- Handle case of three in a row
--Query that answers the question goes below the "insert into" line:
insert into q3
SELECT c1.driver_id, c1.day as start, c3.dur + c2.dur + c1.dur as 
driving, c3.totalbreak + c2.totalbreak + c1.totalbreak as breaks
FROM Combine c1, Combine c2, Combine c3
WHERE c3.day - c2.day = 1
AND c2.day - c1.day = 1;
