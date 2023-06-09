-- Data cleaning and EDA in SQL:

############ Raw data in Bit.io
-- Count the number of distinct users
SELECT COUNT(DISTINCT id) FROM "users";
-- Output: 48,943

-- Count the number of distinct countries
SELECT COUNT(DISTINCT country) FROM "users";
-- Output: 10

-- Count the number of distinct genders
SELECT COUNT(DISTINCT gender) FROM "users";
-- Output: 3

-- Count the number of users where the country is null
SELECT COUNT(id) FROM "users" WHERE country IS NULL;
-- Output: 643

-- Count the number of users where the gender is null
SELECT COUNT(id) FROM "users" WHERE gender IS NULL;
-- Output: 6855

-- Count the number of distinct users in groups
SELECT COUNT(DISTINCT uid) FROM "groups";
-- Output: 48,943

-- Count the number of distinct groups
SELECT COUNT(DISTINCT "group") FROM "groups";
-- Output: 2

-- Count the number of distinct devices
SELECT COUNT(DISTINCT device) FROM "groups";
-- Output: 2

-- Count the number of users in groups where the join_dt is null
SELECT COUNT(uid) FROM "groups" WHERE join_dt IS NULL;
-- Output: 0

-- Count the number of users in groups where the group is null
SELECT COUNT(uid) FROM "groups" WHERE "group" IS NULL;
-- Output: 0

-- Count the number of users in groups where the device is null
SELECT COUNT(uid) FROM "groups" WHERE device IS NULL;
-- Output: 294

-- Count the number of distinct users in activity
SELECT COUNT(DISTINCT uid) FROM "activity";
-- Output: 2094

-- Count the number of users in activity
SELECT COUNT(uid) FROM "activity";
-- Output: 2233

-- Calculate the number of repeat purchases
-- (subtract the number of distinct users from the total number of users)
-- Output: 139

-- Count the number of distinct devices in activity
SELECT COUNT(DISTINCT device) FROM "activity";
-- Output: 2

-- Count the number of users in activity where the device is null
SELECT COUNT(uid) FROM "activity" WHERE "device" IS NULL;
-- Output: 10

-- Count the number of users in activity where the dt is null
SELECT COUNT(uid) FROM "activity" WHERE dt IS NULL;
-- Output: 0

-- Count the number of users in activity where the spent is null
SELECT COUNT(uid) FROM "activity" WHERE spent IS NULL;
-- Output: 0

Sprint quiz

-- Calculate the conversion rate as a percentage
-- Output: 4.28%
SELECT COUNT(*)/48,943*100 FROM "groups";

-- Count the number of groups where join_dt is between the minimum join_dt and '2023-02-01'
SELECT COUNT(*) FROM "groups" 
WHERE  join_dt  BETWEEN (
	SELECT MIN(join_dt) 
	FROM "groups" 
	) 
AND '2023-02-01';
-- Output: 41412


-- Count the number of users in groups A from Canada
SELECT COUNT(*) 
FROM groups AS g
INNER JOIN users AS u
ON g.uid = u.id
WHERE  "group" = 'A' and country = 'CAN';
-- Output: 767


Joining data tables
-- Join users, groups, and activity tables
SELECT *
FROM users
JOIN groups 
ON users.id = groups.uid
LEFT JOIN activity
ON activity.uid = groups.uid



-- Imported joined table from bit.io into SQL server as GloBox A_B Test data

-- Drop duplicate columns uid, uid2, device2 from the table 
ALTER TABLE dbo.[GloBox A_B Test data]
DROP COLUMN uid, uid2, device2;

-- Select the sum of spent with the null values replaced by zero 
SELECT SUM(spent)
FROM (SELECT id, COALESCE(spent, 0) spent
FROM dbo.[GloBox A_B Test data]) as no_null;

-- Replace null values with zero in spent column of GloBox A_B Test data table 
UPDATE dbo.[GloBox A_B Test data]
SET spent = COALESCE(spent, 0);

-- Calculate conversion rate for control and treatment groups 
WITH A_converted AS (
    SELECT COUNT(DISTINCT id) AC
    FROM dbo.[GloBox A_B Test data]
    WHERE spent > 0 AND "group" = 'A'
), A_total AS (
    SELECT COUNT(DISTINCT id) ATo
    FROM dbo.[GloBox A_B Test data]
    WHERE "group" = 'A'
), B_converted AS (
    SELECT COUNT(DISTINCT id) BC
    FROM dbo.[GloBox A_B Test data]
    WHERE spent > 0 AND "group" = 'B'
), B_total AS (
    SELECT COUNT(DISTINCT id) BTo
    FROM dbo.[GloBox A_B Test data]
    WHERE "group" = 'B'
)
SELECT AC, ATo, BC, BTo, (CAST(AC AS float) / CAST(ATo AS float)) * 100 AS CR_A, (CAST(BC AS float) / CAST(BTo AS float)) * 100 AS CR_B
FROM A_converted, A_total, B_converted, B_total;

-- Output: AC: 955 ATo: 24343 BC: 1139 BTo: 24600 CR_A: 3.92%, CR_B: 4.63%
 
-- Calculate summary statistics including average spent per user for control group 
SELECT COUNT(id) as n, AVG(total_spent) as mean, STDEVP(total_spent) as stdevp
FROM (SELECT id, "group", SUM(spent) as total_spent
      FROM dbo.[GloBox A_B Test data]
      GROUP BY id,"group"
      HAVING "group" = 'A') as summ_stats_A;

-- Output: n: 24343, mean: 3.37451847439279, stdevp: 25.9358579885959

-- Calculate summary statistics including average spent per user for treatment group 
SELECT COUNT(id) as n, AVG(total_spent) as mean, STDEVP(total_spent) as stdevp
FROM (SELECT id, "group", SUM(spent) as total_spent
      FROM dbo.[GloBox A_B Test data]
      GROUP BY id,"group"
      HAVING "group" = 'B') as summ_stats_B;
-- Output: n: 24600, mean:3.39086694967819, stdevp: 25.4135931864022
 


