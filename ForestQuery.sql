--Create view
CREATE VIEW forestation AS
SELECT
	r.country_code,
	r.country_name,
	r.region,
	r.income_group,
	f.year,
	f.forest_area_sqkm,
	(l.total_area_sq_mi * 2.59) as land_area_sqkm,
	(f.forest_area_sqkm / (l.total_area_sq_mi * 2.59) * 100) as percentage_forest_land
FROM 
	forest_area f 
	JOIN land_area l ON f.country_code = l.country_code AND f.year = l.year
	JOIN regions r ON l.country_code = r.country_code

--Part 1 - Global Situation:
	--a. What was the total forest area (in sq km) of the world in 1990?
	SELECT forest_area_sqkm FROM forestation WHERE year = 1990 AND country_code = 'WLD';

	--b. What was the total forest area (in sq km) of the world in 2016?
	SELECT forest_area_sqkm FROM forestation WHERE year = 2016 AND country_code = 'WLD'; 

	--c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
	SELECT 
		(SELECT forest_area_sqkm FROM forestation WHERE year = 1990 AND country_code = 'WLD')
			- (SELECT forest_area_sqkm FROM forestation WHERE year = 2016 AND country_code = 'WLD') 
	AS forest_area_change;

	--d. What was the percent change in forest area of the world between 1990 and 2016?
	SELECT
		((SELECT forest_area_sqkm FROM forestation WHERE year = 1990 AND country_code = 'WLD')
			- (SELECT forest_area_sqkm FROM forestation WHERE year = 2016 AND country_code = 'WLD' ))
		/ (SELECT forest_area_sqkm FROM forestation WHERE year = 1990 AND country_code = 'WLD')
		* 100
	AS forest_area_change_percentage;

	--e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?
	SELECT * FROM forestation WHERE year = 2016 AND country_code <> 'WLD' AND land_area_sqkm <= 1324449 ORDER BY land_area_sqkm DESC LIMIT 1;

--Part 2 - Regional Outlook
--a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
	--HIGHEST
	SELECT region, SUM(forest_area_sqkm) / SUM(land_area_sqkm) * 100 AS Forest_Percentage
	FROM forestation 
	WHERE year = 2016 AND country_code <> 'WLD'
	GROUP BY region
    ORDER BY SUM(forest_area_sqkm) / SUM(land_area_sqkm) * 100 DESC
	LIMIT 1;

	--LOWEST
	SELECT region, SUM(forest_area_sqkm) / SUM(land_area_sqkm) * 100 AS Forest_Percentage
	FROM forestation 
	WHERE year = 2016 AND country_code <> 'WLD'
	GROUP BY region
    ORDER BY SUM(forest_area_sqkm) / SUM(land_area_sqkm) * 100
	LIMIT 1;

--b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
	--HIGHEST
	SELECT region, SUM(forest_area_sqkm) / SUM(land_area_sqkm) * 100 AS Forest_Percentage
	FROM forestation 
	WHERE year = 1990 AND country_code <> 'WLD'
	GROUP BY region
    ORDER BY SUM(forest_area_sqkm) / SUM(land_area_sqkm) * 100 DESC
	LIMIT 1;

	--LOWEST
	SELECT region, SUM(forest_area_sqkm) / SUM(land_area_sqkm) * 100 AS Forest_Percentage
	FROM forestation 
	WHERE year = 1990 AND country_code <> 'WLD'
	GROUP BY region
    ORDER BY SUM(forest_area_sqkm) / SUM(land_area_sqkm) * 100
	LIMIT 1;

--c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
	SELECT 
		region,
		SUM(CASE WHEN Year = 1990 THEN forest_area_sqkm ELSE 0 END)
			/ SUM(CASE WHEN Year = 1990 THEN land_area_sqkm ELSE 0 END)
			* 100
		AS Forest_Percentage_1990,
		SUM(CASE WHEN Year = 2016 THEN forest_area_sqkm ELSE 0 END)
			/ SUM(CASE WHEN Year = 2016 THEN land_area_sqkm ELSE 0 END)
			* 100
		AS Forest_Percentage_2016
	FROM forestation
	GROUP BY region
    ORDER BY region;

--Part 3 - Country-Level Detail
--Create view
CREATE VIEW forestation_country_level AS
SELECT 
	country_name,
	region,
	SUM(CASE WHEN Year = 1990 THEN forest_area_sqkm ELSE 0 END) AS Forest_Area_1990,
	SUM(CASE WHEN Year = 1990 THEN land_area_sqkm ELSE 0 END) AS Land_Area_1990,
	SUM(CASE WHEN Year = 1990 THEN forest_area_sqkm ELSE 0 END)
		/ NULLIF(SUM(CASE WHEN Year = 1990 THEN land_area_sqkm ELSE 0 END), 0)
		* 100
	AS Forest_Percentage_1990,
	SUM(CASE WHEN Year = 2016 THEN forest_area_sqkm ELSE 0 END) AS Forest_Area_2016,
	SUM(CASE WHEN Year = 2016 THEN land_area_sqkm ELSE 0 END) AS Land_Area_2016,
	SUM(CASE WHEN Year = 2016 THEN forest_area_sqkm ELSE 0 END) / NULLIF(SUM(CASE WHEN Year = 2016 THEN land_area_sqkm ELSE 0 END), 0) * 100 AS Forest_Percentage_2016
FROM forestation
GROUP BY country_name, region
ORDER BY country_name;

--SUCCESS STORIES
SELECT country_name, (Forest_Area_2016 - Forest_Area_1990) as Forest_Area_Change, (Forest_Area_2016 / NULLIF(Forest_Area_1990, 0) * 100) as Forest_Area_Change_Percent, Forest_Area_2016, Forest_Area_1990
FROM forestation_country_level 
WHERE country_name <> 'World' 
    AND Forest_Area_2016 <> 0
    AND Forest_Area_1990 <> 0
ORDER BY (Forest_Area_2016 - Forest_Area_1990) DESC
LIMIT 2;

--a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
SELECT country_name, region, (Forest_Area_1990 - Forest_Area_2016) as Forest_Area_Change
FROM forestation_country_level 
WHERE country_name <> 'World' 
    AND Forest_Area_2016 <> 0
    AND Forest_Area_1990 <> 0
ORDER BY (Forest_Area_1990 - Forest_Area_2016) DESC
LIMIT 5;

--b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
SELECT country_name, region, ROUND(CAST(((Forest_Area_2016 - Forest_Area_1990) / Forest_Area_1990 * 100) AS NUMERIC), 2) as Forest_Area_Change
FROM forestation_country_level 
WHERE country_name <> 'World' 
    AND Forest_Area_2016 <> 0
    AND Forest_Area_1990 <> 0
ORDER BY ROUND(CAST(((Forest_Area_2016 - Forest_Area_1990) / Forest_Area_1990 * 100) AS NUMERIC), 2)
LIMIT 5;

--c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
SELECT 
    CASE 
		WHEN Forest_Percentage_2016 <= 25 THEN '0 - 25'
		WHEN Forest_Percentage_2016 <= 50 THEN '25 - 50'
		WHEN Forest_Percentage_2016 <= 75 THEN '50 - 75'
		ELSE '75 - 100'
	END AS Group_2016,
    COUNT(*)
FROM forestation_country_level
WHERE country_name <> 'World' 
    AND Forest_Area_2016 <> 0
    AND Forest_Area_1990 <> 0
GROUP BY Group_2016;

--d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
SELECT country_name, region, Forest_Percentage_2016
FROM forestation_country_level
WHERE country_name <> 'World' 
    AND Forest_Area_2016 <> 0
    AND Forest_Area_1990 <> 0
    AND Forest_Percentage_2016 > 75
ORDER BY country_name;



