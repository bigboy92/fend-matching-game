--SONTV9---

CREATE VIEW forestation AS
SELECT fa.country_code, fa.country_name, fa.year, fa.forest_area_sqkm, reg.region, reg.income_group,
la.total_area_sq_mi * 2.59 AS total_area_sqkm, (fa.forest_area_sqkm / (la.total_area_sq_mi * 2.59)) * 100 AS forest_percent
FROM forest_area fa join land_area la on fa.country_code = la. country_code
AND fa.year = la.year
JOIN regions reg ON fa.country_code = reg.country_code;

PART1.a
SELECT fores.forest_area_sqkm
FROM forestation fores
WHERE fores.year = 1990 AND fores.country_name = 'World';
-- 41282694.9

PART1.b
SELECT fores.forest_area_sqkm
FROM forestation fores
WHERE fores.year = 2016 AND fores.country_name = 'World';
-- 39958246

PART1.c
SELECT fores_1990.forest_area_sqkm - fores_2016.forest_area_sqkm
FROM forestation fores_2016, forestation fores_1990
WHERE fores_2016.year = '2016' AND fores_2016.country_name = 'World'
AND   fores_1990.year = '1990' AND fores_1990.country_name = 'World';
--1324449

PART1.d
SELECT (fores_1990.forest_area_sqkm / fores_2016.forest_area_sqkm)*100 - 100
FROM forestation fores_2016, forestation fores_1990
WHERE fores_2016.year = '2016' AND fores_2016.country_name = 'World'
AND   fores_1990.year = '1990' AND fores_1990.country_name = 'World';
-- 3.3145824351614124

PART1.e 
-- flow by result of part1.c the change (in sq km) in the forest area: 1324449
SELECT country_name, ROUND((total_area_sqkm)::NUMERIC, 2) 
FROM forestation
WHERE year='2016' AND total_area_sqkm < 1324449
order by total_area_sqkm desc limit 1;

-- Peru	1279999.99

PART2.a
WITH region_summary AS (
  SELECT 
    region,
    SUM(forest_area_sqkm) AS forest_area,
    SUM(total_area_sqkm) AS land_area
  FROM forestation
  WHERE year = 2016
  GROUP BY region
)
SELECT 
  region,
  forest_area,
  land_area,
  ROUND(((forest_area / land_area) * 100)::NUMERIC, 2) AS forest_percent
FROM region_summary
ORDER BY forest_percent;

--region	forest_area	land_area	forest_percent
--Middle East & North Africa	232131.004009593	11223465.984499997	2.07
--South Asia	835310.4846399999	4771604.0344	17.51
--East Asia & Pacific	6421326.3921158	24361338.4462	26.36
--Sub-Saharan Africa	6115290.9152861	21242361.0679	28.79
--World	39958245.9	127354641.43569998	31.38
--North America	6573934.063	18240983.9864	36.04
--Europe & Central Asia	10438609.30732392	27440113.6114	38.04
--Latin America & Caribbean	9250585.884135248	20039364.446500003	46.16
PART2.b
WITH region_summary AS (
  SELECT 
    region,
    SUM(forest_area_sqkm) AS forest_area,
    SUM(total_area_sqkm) AS land_area
  FROM forestation
  WHERE year = 1990
  GROUP BY region
)
SELECT 
  region,
  forest_area,
  land_area,
  ROUND(((forest_area / land_area) * 100)::NUMERIC, 2) AS forest_percent
FROM region_summary
ORDER BY forest_percent;

--region	forest_area	land_area	forest_percent
--Middle East & North Africa	199292.595698698	11226230.006599998	1.78
--South Asia	789187.09961	4779833.0601	16.51
--East Asia & Pacific	6280252.8421379	24364639.97100001	25.78
--Sub-Saharan Africa	6515615.1999664	21241391.086999997	30.67
--World	41282694.9	127328467.43959999	32.42
--North America	6507240	18252523.9904	35.65
--Europe & Central Asia	10199847.602310268	27357215.0411	37.28
--Latin America & Caribbean	10242341.796304759	20071224.450900003	51.03

PART2.c
WITH region_summary AS (
  SELECT region, year,
    SUM(forest_area_sqkm) AS forest_area,
    SUM(total_area_sqkm) AS land_area
  FROM forestation
  WHERE year IN (1990, 2016)
  GROUP BY region, year
),
region_forest_percent AS (
  SELECT 
    region,
    year,
    ROUND(((forest_area / land_area) * 100)::NUMERIC, 2) AS forest_percent
  FROM region_summary
),
forest_change AS (
  SELECT 
    r1.region,
    r1.forest_percent AS forest_percent_2016,
    r2.forest_percent AS forest_percent_1990,
    r1.forest_percent - r2.forest_percent AS change
  FROM region_forest_percent r1
  JOIN region_forest_percent r2 
    ON r1.region = r2.region AND r1.year = 2016 AND r2.year = 1990
)
SELECT 
  region,
  change
FROM forest_change
WHERE change < 0
ORDER BY change;

--region	change
--Latin America & Caribbean	-4.87
--Sub-Saharan Africa	-1.88
--World	-1.04

PAR3.a
SELECT 
    fores1.country_name, 
    fores1.region,
    ROUND(CAST((fores1.forest_area_sqkm - fores2.forest_area_sqkm) AS NUMERIC), 2) AS change
FROM 
    forestation fores1
JOIN 
    forestation fores2
    ON fores1.country_code = fores2.country_code
    AND fores1.year = '2016'
    AND fores2.year = '1990'
WHERE 
    fores1.country_name != 'World'
    AND fores1.forest_area_sqkm != 0 
    AND fores2.forest_area_sqkm != 0
ORDER BY 
    change DESC
LIMIT 5;

country_name	region	change
China	East Asia & Pacific	527229.06
United States	North America		
India	South Asia	69213.98
Russian Federation	Europe & Central Asia	59395.00
Vietnam	East Asia & Pacific	55390.00

PART3.b
SELECT 
    fores1.country_name, 
    fores1.region, 
    ROUND(CAST((fores1.forest_area_sqkm - fores2.forest_area_sqkm) AS NUMERIC), 2) AS changes
FROM 
    forestation fores1
JOIN 
    forestation fores2
    ON fores1.country_code = fores2.country_code
    AND fores1.year = '2016'
    AND fores2.year = '1990'
WHERE 
    fores1.country_name != 'World'
ORDER BY 
    changes ASC

--country_name	region	changes
--Brazil	Latin America & Caribbean	-541510.00
--Indonesia	East Asia & Pacific	-282193.98
--Myanmar	East Asia & Pacific	-107234.00
--Nigeria	Sub-Saharan Africa	-106506.00
--Tanzania	Sub-Saharan Africa	-102320.00


SELECT 
    fores1.country_name, 
    fores1.region, 
    ROUND(CAST(((fores1.forest_area_sqkm / fores2.forest_area_sqkm - 1) * 100) AS NUMERIC), 2) AS percent_change
FROM 
    forestation fores1
JOIN 
    forestation fores2
    ON fores1.country_code = fores2.country_code
    AND fores1.year = '2016'
    AND fores2.year = '1990'
ORDER BY 
    percent_change ASC
LIMIT 5;

PART3.c
SELECT 
    fores1.country_name, 
    fores1.region, 
    ROUND(CAST(((fores1.forest_area_sqkm / (fores2.forest_area_sqkm + 0.01) - 1) * 100) AS NUMERIC), 2) AS percent_change
FROM 
    forestation AS fores1
JOIN 
    forestation AS fores2
    ON fores1.country_code = fores2.country_code
    AND fores1.year = '2016'
    AND fores2.year = '1990'
WHERE 
    fores2.forest_area_sqkm != 0 
    AND fores1.forest_area_sqkm != 0
ORDER BY 
    percent_change DESC
LIMIT 1;

--country_name	region	percent_change
--Iceland	Europe & Central Asia	213.65

PART3.d
WITH test AS (
    SELECT 
        country_name,
        CASE
            WHEN forest_percent < 25 THEN '0-25%'
            WHEN forest_percent >= 25 AND forest_percent < 50 THEN '25-50%'
            WHEN forest_percent >= 50 AND forest_percent < 75 THEN '50-75%'
            ELSE '75-100%'
        END AS percent
    FROM 
        forestation
    WHERE 
        year = 2016
        AND forest_percent IS NOT NULL
)
SELECT DISTINCT percent, COUNT(country_name) OVER (PARTITION BY percent) AS count
FROM test
ORDER BY percent;

--percent	count
--0-25%	85
--25-50%	73
--50-75%	38
--75-100%	9

WITH test AS (
    SELECT 
        country_name,
		region,
		ROUND((forest_percent)::NUMERIC, 2) AS forest_percent,
        CASE
            WHEN forest_percent < 25 THEN '0-25%'
            WHEN forest_percent >= 25 AND forest_percent < 50 THEN '25-50%'
            WHEN forest_percent >= 50 AND forest_percent < 75 THEN '50-75%'
            ELSE '75-100%'
        END AS percent
    FROM 
        forestation
    WHERE 
        year = 2016
        AND forest_percent IS NOT NULL
)
SELECT country_name, region, percent, forest_percent
FROM test
where percent = '75-100%'
ORDER BY percent;

--country_name	region	percent	forest_percent
--American Samoa	East Asia & Pacific	75-100%	87.50
--Micronesia, Fed. Sts.	East Asia & Pacific	75-100%	91.86
--Gabon	Sub-Saharan Africa	75-100%	90.04
--Guyana	Latin America & Caribbean	75-100%	83.90
--Lao PDR	East Asia & Pacific	75-100%	82.11
--Palau	East Asia & Pacific	75-100%	87.61
--Solomon Islands	East Asia & Pacific	75-100%	77.86
--Suriname	Latin America & Caribbean	75-100%	98.26
--Seychelles	Sub-Saharan Africa	75-100%	88.41

PART3.e
SELECT COUNT(*) AS count
FROM (SELECT country_name FROM forestation
    WHERE forest_percent > ( SELECT forest_percent FROM forestation WHERE country_name = 'United States' AND year = 2016 LIMIT 1 )
    GROUP BY country_name
) AS test;
--count
--100