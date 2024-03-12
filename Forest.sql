-- Create a View called “forestation” by joining all three tables - forest_area, land_area, and regions
CREATE VIEW forestation AS 
SELECT 
  fa.country_code, 
  fa.country_name, 
  re.region, 
  re.income_group, 
  fa.year, 
  fa.forest_area_sqkm, 
  la.total_area_sq_mi * 2.59 AS total_area_sqkm, 
  (
    fa.forest_area_sqkm / (la.total_area_sq_mi * 2.59)
  ) * 100 AS forest_percent 
FROM 
  forest_area AS fa 
  JOIN land_area AS la ON fa.country_code = la.country_code 
  AND fa.year = la.year 
  JOIN regions AS re ON fa.country_code = re.country_code 
ORDER BY 
  country_code, 
  YEAR;

-- Part 1 - Global Situation
-- a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.
SELECT 
  ROUND(forest_area_sqkm) AS forest_area_sqkm_1990 
FROM 
  forestation 
WHERE 
  YEAR = 1990 
  AND country_name = 'World';
-- b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”
SELECT 
  ROUND(forest_area_sqkm) AS forest_area_sqkm_2016 
FROM 
  forestation 
WHERE 
  YEAR = 2016 
  AND country_name = 'World';

-- c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
SELECT 
  sub1.forest_area_sqkm - sub2.forest_area_sqkm AS diff_forest_area_sq_km 
FROM 
  (
    SELECT 
      fa.country_code AS country_code, 
      fa.forest_area_sqkm 
    FROM 
      forest_area fa 
    WHERE 
      fa.country_name = 'World' 
      AND fa.year = 1990
  ) AS sub1 
  JOIN (
    SELECT 
      fa.country_code AS country_code, 
      fa.forest_area_sqkm 
    FROM 
      forest_area fa 
    WHERE 
      fa.country_name = 'World' 
      AND fa.year = 2016
  ) AS sub2 ON sub1.country_code = sub2.country_code;


-- d. What was the percent change in forest area of the world between 1990 and 2016?
SELECT 
  (
    (
      sub1.forest_area_sqkm - sub2.forest_area_sqkm
    )/ sub1.forest_area_sqkm
  )* 100 AS perc_change_fa 
FROM 
  (
    SELECT 
      fa.country_code AS country_code, 
      fa.forest_area_sqkm 
    FROM 
      forest_area fa 
    WHERE 
      fa.country_name = 'World' 
      AND fa.year = 1990
  ) AS sub1 
  JOIN (
    SELECT 
      fa.country_code AS country_code, 
      fa.forest_area_sqkm 
    FROM 
      forest_area fa 
    WHERE 
      fa.country_name = 'World' 
      AND fa.year = 2016
  ) AS sub2 ON sub1.country_code = sub2.country_code;


-- e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?
SELECT 
  DISTINCT fo.country_name, 
  ROUND(fo.total_area_sqkm :: NUMERIC) AS total_area_sqkm, 
  ABS(
    fo.total_area_sqkm - (
      SELECT 
        sub1.forest_area_sqkm - sub2.forest_area_sqkm AS diff_forest_area_sq_km 
      FROM 
        (
          SELECT 
            fa.country_code AS country_code, 
            fa.forest_area_sqkm 
          FROM 
            forest_area fa 
          WHERE 
            fa.country_name = 'World' 
            AND fa.year = 1990
        ) AS sub1 
        JOIN (
          SELECT 
            fa.country_code AS country_code, 
            fa.forest_area_sqkm 
          FROM 
            forest_area fa 
          WHERE 
            fa.country_name = 'World' 
            AND fa.year = 2016
        ) AS sub2 ON sub1.country_code = sub2.country_code
    )
  ) AS diff_fa_la_sqkm 
FROM 
  forestation fo 
WHERE 
  fo.year = 2016 
ORDER BY 
  diff_fa_la_sqkm 
LIMIT 
  1;


-- Part 2 - Regional Outlook
-- a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
SELECT 
  sub.*, 
  ROUND(
    (
      (sub.forest_area / sub.land_area) * 100
    ):: NUMERIC, 
    2
  ) AS forest_percent 
FROM 
  (
    SELECT 
      region, 
      SUM(forest_area_sqkm) AS forest_area, 
      SUM(total_area_sqkm) AS land_area 
    FROM 
      forestation 
    GROUP BY 
      region, 
      year 
    HAVING 
      year = 2016
  ) AS sub 
ORDER BY 
  region;

-- b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
SELECT 
  sub.*, 
  ROUND(
    (
      (sub.forest_area / sub.land_area) * 100
    ):: NUMERIC, 
    2
  ) AS forest_percent 
FROM 
  (
    SELECT 
      region, 
      SUM(forest_area_sqkm) AS forest_area, 
      SUM(total_area_sqkm) AS land_area 
    FROM 
      forestation 
    GROUP BY 
      region, 
      year 
    HAVING 
      year = 1990
  ) AS sub 
ORDER BY 
  region;

-- c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
WITH table1 AS (
  SELECT 
    sub.*, 
    ROUND(
      (
        (sub.forest_area / sub.land_area) * 100
      ):: NUMERIC, 
      2
    ) AS forest_percent 
  FROM 
    (
      SELECT 
        region, 
        SUM(forest_area_sqkm) AS forest_area, 
        SUM(total_area_sqkm) AS land_area 
      FROM 
        forestation 
      GROUP BY 
        region, 
        year 
      HAVING 
        year = 2016
    ) AS sub 
  ORDER BY 
    forest_percent
), 
table2 AS (
  SELECT 
    sub.*, 
    ROUND(
      (
        (sub.forest_area / sub.land_area) * 100
      ):: NUMERIC, 
      2
    ) AS forest_percent 
  FROM 
    (
      SELECT 
        region, 
        SUM(forest_area_sqkm) AS forest_area, 
        SUM(total_area_sqkm) AS land_area 
      FROM 
        forestation 
      GROUP BY 
        region, 
        year 
      HAVING 
        year = 1990
    ) AS sub 
  ORDER BY 
    forest_percent
) 
SELECT 
  table1.region, 
  table1.forest_percent - table2.forest_percent AS change_prc 
FROM 
  table1 
  JOIN table2 ON table1.region = table2.region 
  AND table1.forest_percent < table2.forest_percent 
ORDER BY 
  change_prc;

-- Part 3 - Country-Level Detail
-- a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
WITH table1990 AS (
  SELECT 
    fa.country_code, 
    fa.country_name, 
    fa.year, 
    fa.forest_area_sqkm 
  FROM 
    forest_area fa 
  WHERE 
    fa.year = 1990 
    AND fa.forest_area_sqkm IS NOT NULL 
    AND fa.country_name != 'World'
), 
table2016 AS (
  SELECT 
    fa.country_code, 
    fa.country_name, 
    fa.year, 
    fa.forest_area_sqkm 
  FROM 
    forest_area fa 
  WHERE 
    fa.year = 2016 
    AND fa.forest_area_sqkm IS NOT NULL 
    AND fa.country_name != 'World'
) 
SELECT 
  table1990.country_code, 
  table1990.country_name, 
  re.region, 
  table1990.forest_area_sqkm AS fa_1990_sqkm, 
  table2016.forest_area_sqkm AS fa_2016_sqkm, 
  table1990.forest_area_sqkm - table2016.forest_area_sqkm AS diff_fa_sqkm 
FROM 
  table1990 
  JOIN table2016 ON table1990.country_code = table2016.country_code 
  AND (
    table1990.forest_area_sqkm IS NOT NULL 
    AND table2016.forest_area_sqkm IS NOT NULL
  ) 
  JOIN regions re ON table2016.country_code = re.country_code 
ORDER BY 
  6 DESC 
LIMIT 
  5;

-- b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
WITH table1990 AS (
  SELECT 
    fa.country_code, 
    fa.country_name, 
    fa.year, 
    fa.forest_area_sqkm 
  FROM 
    forest_area fa 
  WHERE 
    fa.year = 1990 
    AND fa.forest_area_sqkm IS NOT NULL 
    AND fa.country_name != 'World'
), 
table2016 AS (
  SELECT 
    fa.country_code, 
    fa.country_name, 
    fa.year, 
    fa.forest_area_sqkm 
  FROM 
    forest_area fa
  WHERE 
    fa.year = 2016 
    AND fa.forest_area_sqkm IS NOT NULL 
    AND fa.country_name != 'World'
) 
SELECT 
  table1990.country_code, 
  table1990.country_name, 
  re.region, 
  table1990.forest_area_sqkm AS fa_1990_sqkm, 
  table2016.forest_area_sqkm AS fa_2016_sqkm, 
  table1990.forest_area_sqkm - table2016.forest_area_sqkm AS diff_fa_sqkm, 
  ABS(
    ROUND(
      CAST(
        (
          (
            table2016.forest_area_sqkm - table1990.forest_area_sqkm
          )/ table1990.forest_area_sqkm * 100
        ) AS NUMERIC
      ), 
      2
    )
  ) AS perc_change 
FROM 
  table1990 
  JOIN table2016 ON table1990.country_code = table2016.country_code 
  AND (
    table1990.forest_area_sqkm IS NOT NULL 
    AND table2016.forest_area_sqkm IS NOT NULL
  ) 
  JOIN regions re ON table2016.country_code = re.country_code 
ORDER BY 
  ROUND(
    CAST(
      (
        (
          table2016.forest_area_sqkm - table1990.forest_area_sqkm
        )/ table1990.forest_area_sqkm * 100
      ) AS NUMERIC
    ), 
    2
  ) 
LIMIT 
  5;


-- c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
WITH sub AS (
  SELECT 
    country_name, 
    CASE WHEN forest_percent < 25 THEN '0-25%' WHEN forest_percent >= 25 
    AND forest_percent < 50 THEN '25-50%' WHEN forest_percent >= 50 
    AND forest_percent < 75 THEN '50-75%' ELSE '75-100%' END AS quartile 
  FROM 
    forestation 
  WHERE 
    year = 2016 
    AND forest_percent IS NOT NULL
) 
SELECT 
  DISTINCT quartile, 
  (
    COUNT(country_name) OVER (PARTITION BY quartile)
  ) AS count 
FROM 
  sub 
ORDER BY 
  quartile;
-- d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
WITH sub AS (
  SELECT 
    country_name, 
    CASE WHEN forest_percent < 25 THEN '0-25%' WHEN forest_percent >= 25 
    AND forest_percent < 50 THEN '25-50%' WHEN forest_percent >= 50 
    AND forest_percent < 75 THEN '50-75%' ELSE '75-100%' END AS quartile 
  FROM 
    forestation 
  WHERE 
    year = 2016 
    AND forest_percent IS NOT NULL
) 
SELECT 
  country_name, 
  quartile 
FROM 
  sub 
WHERE 
  quartile = '75-100%';

-- e. How many countries had a percent forestation higher than the United States in 2016?
SELECT 
  COUNT(*) AS count 
FROM 
  (
    SELECT 
      DISTINCT country_name 
    FROM 
      forestation 
    WHERE 
      forest_percent > (
        SELECT 
          forest_percent 
        FROM 
          forestation 
        WHERE 
          (country_name = 'United States') 
          AND year = 2016
      ) 
    ORDER BY 
      country_name
  ) AS sub;
