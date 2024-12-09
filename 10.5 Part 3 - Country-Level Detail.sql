-- a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
WITH t1_1990 AS
(
SELECT fa_country_name,
  r_region,
  fa_forest_area_sqkm
FROM forestation
WHERE fa_year = 1990
),
t2_2016 AS
(
SELECT fa_country_name,
  fa_forest_area_sqkm
FROM forestation
WHERE fa_year = 2016
)
SELECT t1_1990.fa_country_name, t1_1990.r_region, t1_1990.fa_forest_area_sqkm - t2_2016.fa_forest_area_sqkm AS forest_decrease
FROM t1_1990
JOIN t2_2016
ON t1_1990.fa_country_name = t2_2016.fa_country_name
WHERE (t1_1990.fa_forest_area_sqkm - t2_2016.fa_forest_area_sqkm) != 0
AND t1_1990.fa_country_name != 'World'
ORDER BY 3 DESC
LIMIT 5;
-- Brazil	Latin America & Caribbean	541510
-- Indonesia	East Asia & Pacific	282193.98439999996
-- Myanmar	East Asia & Pacific	107234.00390000001
-- Nigeria	Sub-Saharan Africa	106506.00098
-- Tanzania	Sub-Saharan Africa	102320

-- b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
WITH t1_1990 AS
(
SELECT fa_country_name,
  r_region,
  fa_forest_area_sqkm
FROM forestation
WHERE fa_year = 1990
),
t2_2016 AS
(
SELECT fa_country_name,
  fa_forest_area_sqkm
FROM forestation
WHERE fa_year = 2016
)
SELECT t1_1990.fa_country_name, 
  t1_1990.r_region, 
  ROUND(CAST(((t2_2016.fa_forest_area_sqkm - t1_1990.fa_forest_area_sqkm)/t1_1990.fa_forest_area_sqkm * 100) AS NUMERIC), 2) AS forest_decrease_percent
FROM t1_1990
JOIN t2_2016
ON t1_1990.fa_country_name = t2_2016.fa_country_name
ORDER BY 3
LIMIT 5;
-- Togo	Sub-Saharan Africa	-75.45
-- Nigeria	Sub-Saharan Africa	-61.80
-- Uganda	Sub-Saharan Africa	-59.13
-- Mauritania	Sub-Saharan Africa	-46.75
-- Honduras	Latin America & Caribbean	-45.03

-- c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
SELECT distinct(percent_forest_in_quartiles), COUNT(fa_country_name) OVER (PARTITION BY percent_forest_in_quartiles)
FROM (SELECT fa_country_name,
  CASE WHEN forest_percent_to_land <= 25 THEN '0% to 25%'
  WHEN forest_percent_to_land <= 75 AND forest_percent_to_land > 50 THEN '50% to 75%'
  WHEN forest_percent_to_land <= 50 AND forest_percent_to_land > 25 THEN '25% to 50%'
  ELSE '75% to 100%'
END AS percent_forest_in_quartiles FROM forestation
WHERE forest_percent_to_land > 0 AND fa_year = 2016);
-- 0% to 25%	85
-- 25% to 50%	73
-- 50% to 75%	38
-- 75% to 100%	9

-- d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
SELECT fa_country_name, r_region, forest_percent_to_land
FROM forestation
WHERE forest_percent_to_land > 75 AND fa_year = 2016;
-- American Samoa	East Asia & Pacific	87.5000875000875
-- Micronesia, Fed. Sts.	East Asia & Pacific	91.85723907152479
-- Gabon	Sub-Saharan Africa	90.0376418700565
-- Guyana	Latin America & Caribbean	83.90144891106817
-- Lao PDR	East Asia & Pacific	82.10823176408609
-- Palau	East Asia & Pacific	87.60680854912036
-- Solomon Islands	East Asia & Pacific	77.86351779450665
-- Suriname	Latin America & Caribbean	98.2576939676578
-- Seychelles	Sub-Saharan Africa	88.41113673857889

-- e. How many countries had a percent forestation higher than the United States in 2016?
SELECT COUNT(*) AS countries_higher_than_US
FROM forestation
WHERE
  forest_percent_to_land > (SELECT forest_percent_to_land
FROM forestation
WHERE fa_country_name = 'United States' AND fa_year = 2016)
AND fa_year = 2016;
-- 94