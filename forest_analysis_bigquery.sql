SELECT * FROM `just-oarlock-455900-m3.regions.regions` ;
SELECT * FROM `just-oarlock-455900-m3.forest_area.forest_area` ;
SELECT * FROM `just-oarlock-455900-m3.land_area.land_area` ;

-- Step 3: Create View
CREATE OR REPLACE VIEW `forest_area.forestation` AS
SELECT f.country_code,f.country_name,f.year,f.forest_area_sqkm,l.total_area_sq_mi,
r.region,ROUND((f.forest_area_sqkm/NULLIF(l.total_area_sq_mi*2.59,0))*100,2 ) AS forest_percentage
FROM `forest_area.forest_area` f
JOIN `land_area.land_area` l ON f.country_code = l.country_code AND f.year = l.year
JOIN `regions.regions` r ON f.country_code = r.country_code;

-- Step 4: View Forestation Data
SELECT * FROM `forest_area.forestation`;

-- Step 5: Global Forest Area Change Calculation
CREATE OR REPLACE VIEW `forest_area.global` AS
SELECT a.forest_area_sqkm AS forest_area_1990,
b.forest_area_sqkm AS forest_area_2016,
a.forest_area_sqkm - b.forest_area_sqkm AS area_difference_sqkm,
ROUND(((a.forest_area_sqkm - b.forest_area_sqkm) / NULLIF(a.forest_area_sqkm, 0)) * 100, 2) AS percentage_change
FROM `forest_area.forestation` a
JOIN `forest_area.forestation` b ON a.country_code = b.country_code AND a.country_name = b.country_name AND a.year = 1990 AND b.year = 2016
WHERE a.country_name = 'World';

-- Step 6: Global Forest Area Change Comparison with countries
SELECT * FROM `forest_area.global`;
SELECT l.country_name,l.total_area_sq_mi, l.total_area_sq_mi *2.59 AS total_area_sqkm
FROM `land_area.land_area` l
CROSS JOIN `forest_area.global` g
WHERE year = 2016 AND l.total_area_sq_mi < (g.area_difference_sqkm/2.59)
ORDER BY l.total_area_sq_mi DESC LIMIT 1;

-- Step 7: Regional Outlook Analysis (Highest and Lowest forestation in 1990 & 2016)
WITH CTE AS(
SELECT region,
ROUND((SUM(CASE WHEN year = 1990 THEN forest_area_sqkm ELSE 0 END) / NULLIF(SUM(CASE WHEN year = 1990 THEN total_area_sq_mi END*2.59),0))*100,2) AS forest_percentage_1990,
ROUND((SUM(CASE WHEN year = 2016 THEN forest_area_sqkm ELSE 0 END) / NULLIF(SUM(CASE WHEN year = 2016 THEN total_area_sq_mi END*2.59),0))*100,2) AS forest_percentage_2016
FROM `forest_area.forestation` f
WHERE f.year IN (1990,2016)
GROUP BY region)
SELECT region, forest_percentage_1990,forest_percentage_2016,
CASE
    WHEN forest_percentage_1990 = (SELECT MAX(forest_percentage_1990) FROM CTE) THEN 'Highest in 1990'
    WHEN forest_percentage_1990 = (SELECT MIN(forest_percentage_1990) FROM CTE) THEN 'Lowest in 1990'
    ELSE 'other'
END AS comparison_1990,
CASE
    WHEN forest_percentage_2016 = (SELECT MAX(forest_percentage_2016) FROM CTE) THEN 'Highest in 2016'
    WHEN forest_percentage_2016 = (SELECT MIN(forest_percentage_2016) FROM CTE) THEN 'Lowest in 2016'
    ELSE 'other'
END AS comparison_2016
FROM CTE ORDER BY forest_percentage_2016 DESC;

-- Step 8: Regional Outlook Percent Forest Area by Region
SELECT region,
ROUND((SUM(CASE WHEN year = 1990 THEN forest_area_sqkm ELSE 0 END) / NULLIF(SUM(CASE WHEN year = 1990 THEN total_area_sq_mi END*2.59),0))*100,2) AS forest_percentage_1990,
ROUND((SUM(CASE WHEN year = 2016 THEN forest_area_sqkm ELSE 0 END) / NULLIF(SUM(CASE WHEN year = 2016 THEN total_area_sq_mi END*2.59),0))*100,2) AS forest_percentage_2016
FROM `forest_area.forestation` f
WHERE f.year IN (1990,2016)
GROUP BY region
ORDER BY forest_percentage_2016 DESC;

-- Step 9: COUNTRY-LEVEL DETAIL SUCCESS STORIES
SELECT country_name, year, forest_area_sqkm,
LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) AS previous_area,
forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) AS area_change,
ROUND(((forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year)) / NULLIF(LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year), 0)) * 100, 2) AS percent_change
FROM `forest_area.forestation`
WHERE year IN (1990, 2016)
QUALIFY LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) IS NOT NULL
ORDER BY area_change DESC LIMIT 5;

-- Step 9B: Countries with Largest Percentage Forest Area Increase (1990 to 2016)
SELECT country_name, region, forest_area_sqkm,
LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) AS forest_area_1990,
ROUND(((forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year)) / NULLIF(LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year), 0)) * 100, 2) AS percent_change
FROM `forest_area.forestation`
WHERE year IN (1990, 2016)
QUALIFY LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) IS NOT NULL
ORDER BY percent_change DESC LIMIT 5;

-- Step 10: Countries with largest land area
SELECT country_name, total_area_sq_mi
FROM `forest_area.forestation`
WHERE year = 2016
ORDER BY total_area_sq_mi DESC LIMIT 5;

-- Step 11: LARGEST CONCERNS
SELECT country_name,region, forest_area_sqkm,
LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) AS previous_area,
forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) AS area_change,
ROUND(((forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year)) / NULLIF(LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year), 0)) * 100, 2) AS percent_change
FROM `forest_area.forestation`
WHERE year IN (1990, 2016)
QUALIFY LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) IS NOT NULL
AND forest_area_sqkm < previous_area
ORDER BY area_change LIMIT 6;

-- Step 12: COUNTRIES WITH LARGEST % FOREST AREA DROP
SELECT country_name,region, forest_area_sqkm,
LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) AS previous_area,
forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) AS area_change,
ROUND(((forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year)) / NULLIF(LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year), 0)) * 100, 2) AS percent_change
FROM `forest_area.forestation`
WHERE year IN (1990, 2016)
QUALIFY LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year) IS NOT NULL
AND forest_area_sqkm < previous_area
ORDER BY percent_change LIMIT 5;

-- Step 13: QUARTILES
CREATE OR REPLACE VIEW `forest_area.quartiles` AS
WITH quart AS (
SELECT country_code, country_name, forest_percentage, region,
CASE
    WHEN forest_percentage <= 25 THEN 1
    WHEN forest_percentage <= 50 THEN 2
    WHEN forest_percentage <= 75 THEN 3
    WHEN forest_percentage <= 100 THEN 4
END AS quarts
FROM `forest_area.forestation`
WHERE year = 2016 AND country_code != 'WLD' AND forest_percentage IS NOT NULL)
SELECT * FROM quart;

SELECT quarts, count(*) as No_of_countries
FROM `forest_area.quartiles`
GROUP BY quarts ORDER BY quarts;

-- Step 14: Top Quartile Countries, 2016
SELECT country_name,region,forest_percentage AS Pct_Designated_Forest
FROM `forest_area.quartiles`
WHERE quarts = 4 ORDER BY Pct_Designated_Forest DESC;