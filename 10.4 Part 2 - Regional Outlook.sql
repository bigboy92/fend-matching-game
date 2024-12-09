-- a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
SELECT ROUND(CAST(forest_percent_to_land AS numeric), 2)
FROM forestation
WHERE fa_year = 2016
AND r_country_name = 'World';
-- 31.38%

SELECT r_region,
  ROUND(CAST((SUM(fa_forest_area_sqkm) / (SUM(la_total_area_sq_mi) * 2.59) ) * 100 AS NUMERIC), 2) AS forest_percent_to_land_2016
FROM forestation
WHERE fa_year = 2016
GROUP BY r_region
ORDER BY 2 DESC;
-- Latin America & Caribbean	46.16
-- Middle East & North Africa	2.07

-- b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
SELECT ROUND(CAST(forest_percent_to_land AS numeric), 2)
FROM forestation
WHERE fa_year = 1990
AND r_country_name = 'World';
-- 32.42

SELECT r_region,
  ROUND(CAST((SUM(fa_forest_area_sqkm) / (SUM(la_total_area_sq_mi) * 2.59) ) * 100 AS NUMERIC), 2) AS forest_percent_to_land_1990
FROM forestation
WHERE fa_year = 1990
GROUP BY r_region
ORDER BY 2 DESC;
-- Latin America & Caribbean	51.03
-- Middle East & North Africa	1.78

-- c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
WITH t1_1990 AS
(
SELECT r_region,
  ROUND(CAST((SUM(fa_forest_area_sqkm) / (SUM(la_total_area_sq_mi) * 2.59) ) * 100 AS NUMERIC), 2) AS forest_percent_to_land_1990
FROM forestation
WHERE fa_year = 1990
GROUP BY r_region
),
t2_2016 AS
(
SELECT r_region,
  ROUND(CAST((SUM(fa_forest_area_sqkm) / (SUM(la_total_area_sq_mi) * 2.59) ) * 100 AS NUMERIC), 2) AS forest_percent_to_land_2016
FROM forestation
WHERE fa_year = 2016
GROUP BY r_region
)
SELECT t1_1990.r_region, t1_1990.forest_percent_to_land_1990, t2_2016.forest_percent_to_land_2016
FROM t1_1990
JOIN t2_2016
ON t1_1990.r_region = t2_2016.r_region
ORDER BY r_region;
-- East Asia & Pacific	25.78	26.36
-- Europe & Central Asia	37.28	38.04
-- Latin America & Caribbean	51.03	46.16
-- Middle East & North Africa	1.78	2.07
-- North America	35.65	36.04
-- South Asia	16.51	17.51
-- Sub-Saharan Africa	30.67	28.79
-- World	32.42	31.38
