CREATE VIEW 		forestation AS
		SELECT		fa.country_code,
					fa.country_name,
					fa.year,
					fa.forest_area_sqkm,
					la.total_area_sq_mi,
					r.region,
					r.income_group,
					(forest_area_sqkm/(total_area_sq_mi*2.59)*100) AS forest_percentage
		FROM		forest_area fa
		LEFT JOIN	land_area la ON	fa.country_code = la.country_code AND fa.year = la.year
		LEFT JOIN	regions r ON fa.country_code = r.country_code;

/* 10.3 a. - 1. GLOBALE SITUATION 

WITH	forest_1990 AS (
		SELECT	SUM(forest_area_sqkm) AS total_forest_area_1990
		FROM	forestation
		WHERE	year = 1990 AND region = 'World'
		)

SELECT *
FROM	forest_1990
		
*/

/* 10.3 b.

WITH	forest_2016 AS (
		SELECT	SUM(forest_area_sqkm) AS total_forest_area_2016
		FROM	forestation
		WHERE	year = 2016 AND region = 'World'
		)		

SELECT *
FROM	forest_2016

*/

/* 10.3 c.

WITH	forest_delta_1990_2016 AS (
		SELECT	SUM(CASE WHEN year = 1990 THEN forest_area_sqkm ELSE - forest_area_sqkm END) AS forest_change
		FROM	forestation
		WHERE	year IN (1990, 2016) AND region = 'World'
		)

SELECT	*
FROM	forest_delta_1990_2016

*/
				
/* 10.3 d.

WITH	forest_1990_2016 AS (
		SELECT 	SUM(CASE WHEN year = 2016 THEN forest_area_sqkm ELSE 0 END) AS forest_2016,
			 	SUM(CASE WHEN year = 1990 THEN forest_area_sqkm ELSE 0 END) AS forest_1990
		FROM forestation
		WHERE region = 'World'
		)

SELECT	((forest_1990 - forest_2016)/(forest_1990) * 100) AS forest_1990_2016_percentageloss
FROM	forest_1990_2016

*/

/* 10.3 e.
WITH	ForestLoss_1990_2016 AS (
			SELECT	SUM(CASE WHEN year = 1990 THEN forest_area_sqkm ELSE - forest_area_sqkm END) AS change_forest_1990_2016
			FROM forestation
			WHERE year IN (1990, 2016) AND region = 'World'
			),
		LandArea_2016 AS (
			SELECT country_name, (total_area_sq_mi * 2.59) AS total_land_area_km2
			FROM land_area
			WHERE year = 2016 AND country_name NOT LIKE 'World'
			)
SELECT	LandArea_2016.country_name,
		LandArea_2016.total_land_area_km2
FROM	ForestLoss_1990_2016
CROSS JOIN LandArea_2016
WHERE	LandArea_2016.total_land_area_km2 < ForestLoss_1990_2016.change_forest_1990_2016
ORDER BY 2 DESC
LIMIT 1

*/

/* 10.4 

SELECT		region,
			(SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=1990 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_1990_percentage,
			(SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=2016 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_2016_percentage
FROM		forestation
GROUP BY	1

*/

/* 10.4 a - 2. REGIONALER AUSBLICK

SELECT		region,
			(SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=1990 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_1990_percentage,
			(SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=2016 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_2016_percentage
FROM		forestation
WHERE		region LIKE 'World'
GROUP BY	1



WITH	total_forest_percentage AS (
		SELECT		region,
					(SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=1990 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_1990_percentage,
					(SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=2016 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_2016_percentage
		FROM		forestation
		GROUP BY	1
		)
SELECT	(SELECT	region FROM total_forest_percentage ORDER BY forest_2016_percentage DESC LIMIT 1) AS highest_region,
		(SELECT	forest_2016_percentage FROM total_forest_percentage ORDER BY forest_2016_percentage DESC LIMIT 1) AS highest_percentage,
		(SELECT	region FROM total_forest_percentage ORDER BY forest_2016_percentage LIMIT 1) AS lowest_region,
		(SELECT	forest_2016_percentage FROM total_forest_percentage ORDER BY forest_2016_percentage LIMIT 1) AS lowest_percentage
FROM	total_forest_percentage
LIMIT 1

*/

/* 10.4 b 

SELECT		region,
			(SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=1990 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_1990_percentage,
			(SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=2016 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_2016_percentage
FROM		forestation
WHERE		region like 'Worl%'
GROUP BY	1

WITH	total_forest_percentage AS (
		SELECT		region,
					(SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=1990 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_1990_percentage,
					(SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=2016 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_2016_percentage
		FROM		forestation
		GROUP BY	1
		)
SELECT	(SELECT	region FROM total_forest_percentage ORDER BY forest_1990_percentage DESC LIMIT 1) AS highest_region,
		(SELECT	forest_1990_percentage FROM total_forest_percentage ORDER BY forest_1990_percentage DESC LIMIT 1) AS highest_percentage,
		(SELECT	region FROM total_forest_percentage ORDER BY forest_1990_percentage LIMIT 1) AS lowest_region,
		(SELECT	forest_1990_percentage FROM total_forest_percentage ORDER BY forest_1990_percentage LIMIT 1) AS lowest_percentage
FROM	total_forest_percentage
LIMIT 1

*/

/* 10.4 c 

WITH table_1 AS (
		SELECT		region,
					(SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=1990 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_1990_percentage,
					(SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) / SUM(CASE WHEN year=2016 THEN (total_area_sq_mi * 2.59) ELSE 0 END))*100 AS forest_2016_percentage
		FROM		forestation
		GROUP BY	1
		)

SELECT	region,
		forest_1990_percentage,
		forest_2016_percentage
FROM table_1
WHERE forest_2016_percentage < forest_1990_percentage AND region not LIKE 'World'

*/

/* 10.5 a - 3. DETAILS AUF LÄNDEREBENE

WITH country_forest_area AS (
			SELECT		country_name,
						region,
						SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) as total_forest_area_1990,
						SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) as total_forest_area_2016
			FROM		forestation
			WHERE		region not like 'World'
			GROUP BY 	country_name, region
			)

SELECT	country_name,
		region,
		(total_forest_area_1990-total_forest_area_2016) AS absolut_forest_change
FROM	country_forest_area
ORDER BY absolut_forest_change DESC
LIMIT 5


3.a

WITH country_forest_area AS (
			SELECT		country_name,
						region,
						SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) as total_forest_area_1990,
						SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) as total_forest_area_2016
			FROM		forestation
			WHERE		region not like 'World'
			GROUP BY 	country_name, region	
			)

SELECT	country_name,
		region,
		total_forest_area_1990,
		total_forest_area_2016,
		((total_forest_area_2016-total_forest_area_1990)/NULLIF(total_forest_area_1990,0))*100 AS percentage_forest_change,
		(total_forest_area_1990-total_forest_area_2016) AS absolut_forest_change
FROM	country_forest_area
ORDER BY absolut_forest_change

*/

/* 10.5.b 

WITH country_forest_area AS (
			SELECT		country_name,
						region,
						SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) as total_forest_area_1990,
						SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) as total_forest_area_2016
			FROM		forestation
			WHERE		region not like 'World'
			GROUP BY 	country_name, region	
			)

SELECT	country_name,
		region,
		total_forest_area_1990,
		total_forest_area_2016,
		(ABS(total_forest_area_2016-total_forest_area_1990)/NULLIF(total_forest_area_1990,0))*100 AS percentage_forest_change,
		(total_forest_area_1990-total_forest_area_2016) AS absolute_forest_change
FROM	country_forest_area
WHERE	(total_forest_area_1990-total_forest_area_2016) > 0
ORDER BY percentage_forest_change DESC
LIMIT 5

*/

/* 10.5 c 

WITH	forest_quartiles_2016 AS (
			SELECT		DISTINCT(country_name),
						region,
						forest_percentage,
						NTILE(4) OVER (ORDER BY forest_percentage) AS quartile						
			FROM		forestation
			WHERE		year=2016
					AND	region not like 'World'
					AND	forest_percentage IS NOT NULL
			)

SELECT	quartile,
		COUNT(*) AS num_countries

FROM	forest_quartiles_2016
GROUP BY 1
ORDER BY 1

*/

/* 10.5 d

WITH	forest_quartiles_2016 AS (
			SELECT		country_name,
						region,
						forest_percentage,
						NTILE(4) OVER (ORDER BY forest_percentage) AS quartile						
			FROM		forestation
			WHERE		year=2016
					AND	region NOT LIKE 'World'
					AND	forest_percentage IS NOT NULL
		)

SELECT	quartile,
		country_name,
		region,
		forest_percentage
FROM	forest_quartiles_2016
WHERE	quartile=4 and forest_percentage > 75
GROUP BY 1,2,3,4
ORDER BY 4 DESC
 
 */

/* 10.5 e

WITH	forest_US AS (
			SELECT		forest_percentage
			FROM		forestation
			WHERE		year=2016
					AND	region NOT LIKE 'World'
					AND	forest_percentage IS NOT NULL
					AND country_name like 'United States'
		)

SELECT	COUNT(country_name)
FROM	forestation
WHERE	year=2016 
	AND	forest_percentage > (SELECT forest_percentage FROM forest_US)
	AND	region NOT LIKE 'World'
	AND	forest_percentage IS NOT NULL

 */






































