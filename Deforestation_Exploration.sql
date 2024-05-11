CREATE VIEW forestation AS
	SELECT 
	fa.country_code,
	fa.country_name,
	fa.year,
	fa.forest_area_sqkm,
	la.total_area_sq_mi,
	r.region,
	r.income_group,
	fa.forest_area_sqkm/(la.total_area_sq_mi*2.59)*100 AS percent_of_forest_land 
	FROM forest_area AS fa
	JOIN land_area AS la ON la.country_code = fa.country_code AND la.year = fa.year
	JOIN regions AS r ON r.country_code = fa.country_code

--GLOBAL SITUATION
 --a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.
SELECT forest_area_sqkm FROM forestation WHERE year=1990 AND country_name='World'

 --b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”
SELECT forest_area_sqkm FROM forestation WHERE year=2016 AND country_name='World'

 --c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
SELECT f1.forest_area_sqkm-f2.forest_area_sqkm
FROM forestation f1
INNER JOIN forestation f2 ON f1.country_name='World' 
	AND f1.year=1990 AND f2.country_name='World' AND  f2.year=2016

 --d. What was the percent change in forest area of the world between 1990 and 2016?
SELECT ROUND((100*(f1.forest_area_sqkm - f2.forest_area_sqkm) /f1.forest_area_sqkm)::NUMERIC, 2)
FROM forestation f1
INNER JOIN forestation f2 ON f1.country_name='World' 
	AND f1.year=1990 AND f2.country_name='World' AND  f2.year=2016

 --e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?
WITH 
data_year_1990 AS(SELECT forest_area_sqkm::NUMERIC FROM forestation WHERE year=1990 AND country_name='World'),
data_year_2016 AS(SELECT forest_area_sqkm::NUMERIC FROM forestation WHERE year=2016 AND country_name='World')
SELECT forestation.country_name, forestation.total_area_sq_mi*2.59 as total_area_sqkm
FROM data_year_2016, data_year_1990, forestation
WHERE forestation.total_area_sq_mi*2.59<=data_year_1990.forest_area_sqkm - data_year_2016.forest_area_sqkm
ORDER BY forestation.total_area_sq_mi DESC
LIMIT 1


-- REGION OUTLOOK
 --a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
SELECT region,ROUND((SUM(forest_area_sqkm)*100/SUM(total_area_sq_mi*2.59))::NUMERIC,2) AS percent
FROM forestation
WHERE year=2016 
GROUP BY region
ORDER BY percent

 --b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
SELECT region,ROUND((SUM(forest_area_sqkm)*100/SUM(total_area_sq_mi*2.59))::NUMERIC,2) AS percent
FROM forestation
WHERE year=1990
GROUP BY region
ORDER BY percent

 --c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
WITH 
data_year_2016 AS(
	SELECT region,ROUND((SUM(forest_area_sqkm)*100/SUM(total_area_sq_mi*2.59))::NUMERIC,2) AS percent
	FROM forestation
	WHERE year=2016 
	GROUP BY region
	ORDER BY percent
),
data_year_1990 AS(
	SELECT region,ROUND((SUM(forest_area_sqkm)*100/SUM(total_area_sq_mi*2.59))::NUMERIC,2) AS percent
	FROM forestation
	WHERE year=1990
	GROUP BY region
	ORDER BY percent
)
SELECT data_year_2016.region, data_year_1990.percent AS percent1990, data_year_2016.percent AS percent2016
FROM data_year_2016
INNER JOIN data_year_1990 ON data_year_1990.region=data_year_2016.region


--COUNTRY - LEVEL DETAIL
 --a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
WITH 
data_year_2016 AS(
	SELECT region, country_name, SUM(forest_area_sqkm) AS area
	FROM forestation
	WHERE year = 2016
	GROUP BY region, country_name
),
data_year_1990 AS(
	SELECT region, country_name, SUM(forest_area_sqkm) AS area
	FROM forestation
	WHERE year = 1990
	GROUP BY region, country_name
)
SELECT data_year_2016.country_name AS country, data_year_2016.region, (data_year_1990.area-data_year_2016.area) AS area
FROM data_year_2016
LEFT JOIN data_year_1990 ON data_year_1990.region = data_year_2016.region AND data_year_1990.country_name = data_year_2016.country_name
ORDER BY area ASC
LIMIT 5

 --b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
WITH 
data_year_2016 AS(
	SELECT region, country_name, SUM(forest_area_sqkm) AS area
	FROM forestation
	WHERE year=2016
	GROUP BY region, country_name
),
data_year_1990 AS(
	SELECT region, country_name, SUM(forest_area_sqkm) AS area
	FROM forestation
	WHERE year=1990
	GROUP BY region, country_name
)
SELECT data_year_2016.region, data_year_2016.country_name, ROUND(((data_year_1990.area-data_year_2016.area)/data_year_1990.area)::NUMERIC, 2) AS area
FROM data_year_2016
INNER JOIN data_year_1990 ON data_year_1990.region=data_year_2016.region AND data_year_1990.country_name=data_year_2016.country_name
AND data_year_1990.area>data_year_2016.area
ORDER BY area DESC
LIMIT 5

 --c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
WITH 
groupByPercent AS(
	SELECT
	CASE
		WHEN percent_of_forest_land < 25 
		THEN '0%-25%'
		WHEN percent_of_forest_land >= 25 AND percent_of_forest_land < 50 
		THEN '25%-50%'
		WHEN percent_of_forest_land >= 50 AND percent_of_forest_land < 75 
		THEN '50%-75%'
		ELSE '75%-100%'
	END
	AS quartiles
	FROM forestation
	WHERE year = 2016 AND percent_of_forest_land IS NOT NULL AND country_name != 'World'
	ORDER BY quartiles
)
SELECT DISTINCT quartiles, count(*)
FROM groupByPercent
GROUP BY quartiles
ORDER BY count DESC

 --d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
WITH 
groupByPercent AS(
	SELECT
	country_name,
	percent_of_forest_land,
	region,
	CASE
		WHEN percent_of_forest_land<25 
		THEN '0%-25%'
		WHEN percent_of_forest_land>=25 AND percent_of_forest_land<50 
		THEN '25%-50%'
		WHEN percent_of_forest_land>=50 AND percent_of_forest_land<75 
		THEN '50%-75%'
		ELSE '75%-100%'
	END
	AS quartile
	FROM forestation
	WHERE year = 2016 AND percent_of_forest_land IS NOT NULL AND country_name!='World'
	ORDER BY quartile
)
SELECT country_name AS country, region, ROUND(percent_of_forest_land::NUMERIC, 2) AS area
FROM groupByPercent
WHERE quartile='75%-100%'

 --e. How many countries had a percent forestation higher than the United States in 2016?
SELECT COUNT(*) 
FROM(
SELECT DISTINCT country_name
FROM forestation
WHERE percent_of_forest_land IS NOT NULL
	AND percent_of_forest_land > 
		(
		  SELECT percent_of_forest_land 
		  FROM forestation
		  WHERE country_name='United States' AND year = 2016
		)
)
AS data 