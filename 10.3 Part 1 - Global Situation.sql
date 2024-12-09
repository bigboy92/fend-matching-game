-- a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.
SELECT r_country_name, fa_forest_area_sqkm
FROM forestation 
WHERE r_country_name = 'World'
AND fa_year = 1990;
-- 41282694.9

-- b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”
SELECT r_country_name, fa_forest_area_sqkm
FROM forestation 
WHERE r_country_name = 'World'
AND fa_year = 2016;
-- 39958245.9

-- c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
WITH t1 AS
(SELECT r_country_name, fa_forest_area_sqkm
FROM forestation 
WHERE r_country_name = 'World'
AND fa_year = 1990),
t2 AS
(SELECT r_country_name, fa_forest_area_sqkm
FROM forestation 
WHERE r_country_name = 'World'
AND fa_year = 2016)
SELECT t1.fa_forest_area_sqkm AS fa_1990, t2.fa_forest_area_sqkm AS fa_2016, t1.fa_forest_area_sqkm - t2.fa_forest_area_sqkm AS change_fa
FROM t1
JOIN t2
ON t1.r_country_name = t2.r_country_name;
-- 1324449

-- d. What was the percent change in forest area of the world between 1990 and 2016?
WITH t1 AS
(SELECT r_country_name, fa_forest_area_sqkm
FROM forestation 
WHERE r_country_name = 'World'
AND fa_year = 1990),
t2 AS
(SELECT r_country_name, fa_forest_area_sqkm
FROM forestation 
WHERE r_country_name = 'World'
AND fa_year = 2016)
SELECT t1.fa_forest_area_sqkm AS fa_1990, 
  t2.fa_forest_area_sqkm AS fa_2016, 
  t1.fa_forest_area_sqkm - t2.fa_forest_area_sqkm AS change_fa,
  (t1.fa_forest_area_sqkm - t2.fa_forest_area_sqkm)/t1.fa_forest_area_sqkm * 100 AS per_change
FROM t1
JOIN t2
ON t1.r_country_name = t2.r_country_name;
--3.20824258980244 %

-- e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?
SELECT r_country_name, (la_total_area_sq_mi * 2.59) AS total_area
FROM forestation
WHERE la_year = 2016
ORDER BY 2 DESC;
-- Peru 1279999.9891