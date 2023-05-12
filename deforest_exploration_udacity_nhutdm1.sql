CREATE VIEW forestation 
AS
	SELECT 
    	land_area.country_name, 
        land_area.country_code, 
        land_area.year, 
        land_area.total_area_sq_mi, 
        forest_area.forest_area_sqkm, 
        regions.region, regions.income_group,
        (forest_area.forest_area_sqkm / (land_area.total_area_sq_mi * 2.59)) * 100 AS forest_pc
	FROM ((land_area
		INNER JOIN forest_area 
        	ON land_area.country_code = forest_area.country_code 
            	AND land_area.year = forest_area.year)
		INNER JOIN regions on land_area.country_code = regions.country_code)
		
1. GLOBAL SITUATION
	
a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.

SELECT forest_area_sqkm 
FROM forestation 
WHERE region='World' and year='1990'

b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”

SELECT forest_area_sqkm 
FROM forestation 
WHERE region='World' and year='2016'

c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?

SELECT B-A as forest_lost_1990_2016
FROM 
	(SELECT forest_area_sqkm  AS A
	FROM forestation 
	WHERE region='World' and year='2016') AS forest_2016,
	(SELECT forest_area_sqkm  AS B
	FROM forestation 
	WHERE region='World' and year='1990') AS forest_1990
	
d. What was the percent change in forest area of the world between 1990 and 2016?

SELECT 100-ROUND(A/B*100) as percent_forest_lost_1990_2016
FROM 
	(SELECT forest_area_sqkm  AS A
	FROM forestation 
	WHERE region='World' and year='2016') AS forest_2016,
	(SELECT forest_area_sqkm  AS B
	FROM forestation 
	WHERE region='World' and year='1990') AS forest_1990
	
e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

SELECT country_name, forest_area_sqkm
FROM forestation, 
	(SELECT B-A as forest_lost_1990_2016
	FROM 
	(SELECT forest_area_sqkm  AS A
	FROM forestation 
	WHERE region='World' and year='2016') AS forest_2016,
	(SELECT forest_area_sqkm  AS B
	FROM forestation 
	WHERE region='World' and year='1990') AS forest_1990) as forest_lost_1990_2016
WHERE forest_area_sqkm >= forest_lost_1990_2016 AND year=2016
ORDER BY forest_area_sqkm
LIMIT 1

2. REGIONAL OUTLOOK

a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?

SELECT region, ROUND(((forest_area/land_area)*100)::NUMERIC, 2) AS pc_forest
FROM (SELECT region, SUM(forest_area_sqkm) AS forest_area,
      SUM(total_area_sq_mi)*2.59 AS land_area
FROM forestation
GROUP BY region, year
HAVING year = 2016 ) as A
ORDER BY pc_forest 

b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?

same with a. but year=1990

c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?

see table we created by 2 queris in a. and b.

SELECT table_1990.region, pc_forest_2016, pc_forest_1990
FROM
(SELECT region, ROUND(((forest_area/land_area)*100)::NUMERIC, 2) AS pc_forest_2016
FROM (SELECT region, SUM(forest_area_sqkm) AS forest_area,
      SUM(total_area_sq_mi)*2.59 AS land_area
FROM forestation
GROUP BY region, year
HAVING year = 2016 ) as A 
ORDER BY pc_forest_2016) as table_2016 INNER JOIN
(SELECT region, ROUND(((forest_area/land_area)*100)::NUMERIC, 2) AS pc_forest_1990
FROM (SELECT region, SUM(forest_area_sqkm) AS forest_area,
      SUM(total_area_sq_mi)*2.59 AS land_area
FROM forestation
GROUP BY region, year
HAVING year = 1990 ) as A
ORDER BY pc_forest_1990) as table_1990 ON table_1990.region = table_2016.region
ORDER BY table_1990.region


3. COUNTRY-LEVEL DETAIL

a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?

SELECT country_name, region, ROUND((area_2016-area_1990)::NUMERIC, 2) AS absolute_forest_area_change
FROM ((SELECT country_code, country_name, region, ROUND(forest_area_sqkm::NUMERIC, 2) AS area_1990
FROM forestation
WHERE year=1990) AS table_1990 JOIN (SELECT country_code, ROUND(forest_area_sqkm::NUMERIC, 2) AS area_2016
FROM forestation
WHERE year=2016) AS table_2016 ON table_2016.country_code = table_1990.country_code) AS A
WHERE area_1990 IS NOT NULL AND area_2016 IS NOT NULL
ORDER BY absolute_forest_area_change DESC
LIMIT 5

b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?

SELECT *, ROUND(((area_2016/area_1990)*100)::NUMERIC, 2) as forest_area_diff
FROM ((SELECT country_name, ROUND(forest_area_sqkm::NUMERIC, 2) AS area_1990
FROM forestation
WHERE year=1990) AS table_1990 JOIN (SELECT country_name, ROUND(forest_area_sqkm::NUMERIC, 2) AS area_2016
FROM forestation
WHERE year=2016) AS table_2016 ON table_2016.country_name = table_1990.country_name) AS A
WHERE area_1990 IS NOT NULL AND area_2016 IS NOT NULL
ORDER BY forest_area_diff ASC
LIMIT 5

c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
WITH table_forest AS (
  SELECT country_name,
    CASE
      WHEN forest_pc < 25 THEN '0-25%'
      WHEN forest_pc >= 25
      AND forest_pc < 50 THEN '25-50%'
      WHEN forest_pc >= 50
      AND forest_pc < 75 THEN '50-75%'
      ELSE '75-100%'
    END AS quartile
  FROM forestation
  WHERE year = 2016 AND forest_pc IS NOT NULL
)
SELECT DISTINCT quartile,
  (COUNT(country_name) OVER (PARTITION BY quartile)) AS number_of_countries
FROM table_forest
ORDER BY quartile;

d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.

WITH table_forest AS (
  SELECT country_name, region, 
    CASE
      WHEN forest_pc < 25 THEN '0-25%'
      WHEN forest_pc >= 25
      AND forest_pc < 50 THEN '25-50%'
      WHEN forest_pc >= 50
      AND forest_pc < 75 THEN '50-75%'
      ELSE '75-100%'
    END AS quartile
  FROM forestation
  WHERE year = 2016
    AND forest_pc IS NOT NULL
)
SELECT country_name, region, quartile
FROM table_forest
WHERE quartile = '75-100%';