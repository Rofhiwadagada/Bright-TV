---EDA
---base table
---userid,channel2,recorddate2,duration2 
SELECT *
FROM workspace.brighttv.viewership;

---checking data type
  Describe  workspace.tv.viewership;

----checking duplicates
SELECT count(*) as `row count`--10000
, count(distinct UserID) as `total customer` ----4386 Customers
FROM workspace.brighttv.viewership;

---count total channel  21 Channels
SELECT  count(distinct Channel2)as `total channels`
FROM workspace.brighttv.viewership;

--- Checking months 
SELECT date_format(recorddate2, 'MMM') AS Month_name  
from workspace.brighttv.viewership
group by Month_name 

---checking dates  2016-01-01  to  2016-03-31  duration is 3 months

SELECT MIN(recorddate2) AS Min_date,
       MAX(recorddate2) AS Max_date
from workspace.brighttv.viewership;


-----Checking ---null values  NO Null
select recorddate2, Channel2, `Duration 2`
from workspace.brighttv.viewership
where channel2 IS NULL
  OR recorddate2 IS NULL
  OR  `Duration 2` IS NULL;


  -----Separate the timestamp columns into two separate columns - one containing just the date, the other just containing the time.
SELECT 
recorddate2 AS TIMESTAMP_VALUE,
CAST(recorddate2 AS DATE) AS DATE_PART,
date_format(recorddate2, 'HH:mm:ss') AS TIME_PART
from workspace.brighttv.viewership;

-----Second table

---userid,gender,age,race,province  -------Name,Surname,Email and Social Media Handle  are not included 
select *
FROM workspace.brighttv.userprofile;

----checking data type
describe workspace.brighttv.userprofile;

--checking null value
 select UserID,gender,age,race,province
 from workspace.brighttv.userprofile
 WHERE userid is null or gender is null or age is null or race is null or province is null;----no null

 ----checking duplicates
      select count(*) as `row count`,
      count (distinct userid) as customer 
 from workspace.brighttv.userprofile;

---checking gender column
select distinct gender 
from workspace.brighttv.userprofile;

--checking number of customers per province
SELECT Count(distinct userID) AS User_count_by_province,Province
FROM workspace.brighttv.userprofile
GROUP BY PROVINCE
ORDER BY  User_count_by_province DESC;

-----------------------Main Queries----------------------------
SELECT  
    A.UserID,
    A.Channel2,
    A.recorddate2,
    A.`Duration 2`,
    B.Age,
    
    recorddate2 AS TIMESTAMP_VALUE,
    CAST(recorddate2 AS DATE) AS DATE_PART,
    date_format(recorddate2, 'HH:mm:ss') AS TIME_PART,
    date_format(recorddate2, 'MMM') AS Month_name,
    date_format(recorddate2, 'MM-yyyy') AS Month_id,
    date_format(recorddate2, 'EEE') AS Weekday,
    date_format(`duration 2`, 'HH:mm') AS DURATION,
 
    case 
        when B.gender is null or trim(B.gender) = '' or B.gender = 'None' then 'unknown'
        else B.gender
    end as gender,

    case when B.race in ('other/none comined') then 'Unknown'
        when trim(B.race) ='' or B.race ='None' then 'unknown'
        else B.Race
    end as Race,

    case when trim(B.Province) ='' or B.Province ='None' then 'unknown'    
        else B.Province
    end as Province,

    -- Duration Group
    CASE
        WHEN `Duration 2` BETWEEN '00:00' AND '00:14' THEN 'Short_View_00:00-00:14'
        WHEN `Duration 2` BETWEEN '00:15' AND '00:59' THEN 'Standard_View_00:15-00:59'
        WHEN `Duration 2` BETWEEN '01:00' AND '02:59' THEN 'Engaged_View_01:00-02:59'
        ELSE 'Marathon_View_03:00-11:59'
    END AS Duration_Group,

    -- Time of Day Group
    CASE
        WHEN date_format(recorddate2, 'HH:mm') BETWEEN '06:00' AND '11:59' THEN 'Morning_06:00-11:59'
        WHEN date_format(recorddate2, 'HH:mm') BETWEEN '12:00' AND '16:59' THEN 'Afternoon_12:00-16:59'
        WHEN date_format(recorddate2, 'HH:mm') BETWEEN '17:00' AND '21:59' THEN 'Evening_17:00-21:59'
        ELSE 'Night_22:00-05:59'
    END AS Time_Group,

    -- Age Group
    CASE
        WHEN B.age BETWEEN 0 AND 12 THEN 'Children_0-12'
        WHEN B.age BETWEEN 13 AND 19 THEN 'Teen_13-19'
        WHEN B.age BETWEEN 20 AND 39 THEN 'Young_Adults_20-39'
        WHEN B.age BETWEEN 40 AND 59 THEN 'Middle_Aged_Adults_40-59'
        ELSE 'Seniors_60+'
    END AS Age_Basket,

    COUNT(A.userid) AS Total_Viewership,
    COUNT(DISTINCT A.userid) AS Total_Customers,
    COUNT(A.channel2) AS Total_Channel_Views,
    COUNT(DISTINCT A.channel2) AS Total_Channels,
    ROUND(AVG(B.age), 0) AS Average_Age

FROM workspace.brighttv.viewership as A
LEFT JOIN workspace.brighttv.userprofile as B
    ON A.UserID = B.UserID

GROUP BY 
    DATE_PART, Month_Name, Month_ID, Weekday, Time_PART, Duration, 
    Duration_Group, Time_Group, Age_Basket, gender, race, A.CHANNEL2,
    Province, B.AGE, A.USERID, A.recorddate2, A.`Duration 2`

ORDER BY
    Month_ID, DATE_PART, Time_PART
