-- PART 1 
-- GLOBAL SITUATION

---Q1 and Q2: 
SELECT
  CASE WHEN year = 1990 THEN ROUND(forest_area_sqkm) END AS forest_area_sqkm_1990,
  CASE WHEN year = 2016 THEN ROUND(forest_area_sqkm) END AS forest_area_sqkm_2016
FROM forestation
WHERE country_name = 'World'
  AND year IN (1990, 2016);

  --Q3: 
  SELECT
  ROUND(
    (SELECT forest_area_sqkm FROM forestation WHERE year = 1990 AND country_name = 'World') -
    (SELECT forest_area_sqkm FROM forestation WHERE year = 2016 AND country_name = 'World')
  ) AS forest_area_change;

-- Q4: 
SELECT
  CAST(
    ROUND(
      (
        (
          (SELECT forest_area_sqkm::NUMERIC FROM forestation WHERE year = 1990 AND country_name = 'World') -
          (SELECT forest_area_sqkm::NUMERIC FROM forestation WHERE year = 2016 AND country_name = 'World')
        ) / (SELECT forest_area_sqkm::NUMERIC FROM forestation WHERE year = 1990 AND country_name = 'World')
      ) * 100, 2
    ) AS VARCHAR
  ) || '%' AS forest_area_change;


--Q5: 
WITH forest_area_change AS (
  SELECT
    (SELECT forest_area_sqkm FROM forestation WHERE year = 1990 AND country_name = 'World') -
    (SELECT forest_area_sqkm FROM forestation WHERE year = 2016 AND country_name = 'World') AS forest_area_change
)
SELECT DISTINCT
  country_name,
  ROUND(total_area_sqkm::NUMERIC) AS total_area_sqkm
FROM forestation
WHERE total_area_sqkm >= (SELECT forest_area_change FROM forest_area_change)
ORDER BY total_area_sqkm
LIMIT 1;


-- PART 2 
-- REGIONAL OUTLOOK
--Q1 
SELECT sub.*,
  ROUND(
    ((CAST(sub.forest_area AS NUMERIC) / CAST(sub.land_area AS NUMERIC)) * 100), 2
  ) AS forest_percent
FROM (
  SELECT region,
    SUM(forest_area_sqkm) AS forest_area,
    SUM(total_area_sqkm) AS land_area
  FROM forestation
  WHERE year = 2016
  GROUP BY region
) AS sub
ORDER BY region;

--Q2
SELECT sub.*,
  ROUND(
    ((CAST(sub.forest_area AS NUMERIC) / CAST(sub.land_area AS NUMERIC)) * 100), 2
  ) AS forest_percent
FROM (
  SELECT region,
    SUM(forest_area_sqkm) AS forest_area,
    SUM(total_area_sqkm) AS land_area
  FROM forestation
  WHERE year = 1990
  GROUP BY region
) AS sub
ORDER BY region;


-- PART 3
-- COUNTRY-LEVEL DETAIL
--Q1: Top 5 Amount Decrease in Forest Area by Country, 1990 & 2016:
SELECT
  f1.country_name,
  f1.region,
  f1.forest_area_sqkm AS forest_area_1990,
  f2.forest_area_sqkm AS forest_area_2016,
  ROUND(CAST((f2.forest_area_sqkm - f1.forest_area_sqkm) AS numeric), 2) AS change
FROM (
  SELECT country_code, country_name, region, forest_area_sqkm
  FROM forestation
  WHERE year = 1990 AND country_name <> 'World'
) f1
JOIN (
  SELECT country_code, forest_area_sqkm
  FROM forestation
  WHERE year = 2016
) f2
  ON f1.country_code = f2.country_code
ORDER BY change
LIMIT 5;


-- Q2:Top 5 Percent Decrease in Forest Area by Country, 1990 & 2016:
SELECT
  CASE WHEN f1.country_name <> 'World' THEN f1.country_name END AS country_name,
  f1.region,
  f1.forest_area_sqkm AS forest_area_1990,
  f2.forest_area_sqkm AS forest_area_2016,
  ROUND(-((1 - CAST((f2.forest_area_sqkm / f1.forest_area_sqkm) AS numeric)) * 100), 2) AS change_prc
FROM (
  SELECT country_code, country_name, region, forest_area_sqkm
  FROM forestation
  WHERE year = 1990
) f1
JOIN (
  SELECT country_code, forest_area_sqkm
  FROM forestation
  WHERE year = 2016
) f2
  ON f1.country_code = f2.country_code
  AND f2.forest_area_sqkm < f1.forest_area_sqkm
ORDER BY change_prc
LIMIT 5;


--Q3 Count of Countries Grouped by Forestation Percent Quartiles, 2016:
CREATE TEMPORARY TABLE tmp_quartiles AS
SELECT
  CASE
    WHEN forest_percent < 25 THEN '0-25%'
    WHEN forest_percent >= 25 AND forest_percent < 50 THEN '25-50%'
    WHEN forest_percent >= 50 AND forest_percent < 75 THEN '50-75%'
    ELSE '75-100%'
  END AS quartile,
  country_name
FROM forestation
WHERE year = 2016 AND forest_percent IS NOT NULL;

SELECT
  quartile,
  COUNT(*) AS count
FROM tmp_quartiles
GROUP BY quartile
ORDER BY quartile;

-- Q4: Top Quartile Countries, 2016:
WITH quartiles AS (
  SELECT
    country_name,
  region,
  forest_percent,
    CASE
      WHEN forest_percent < 25 THEN '0-25%'
      WHEN forest_percent >= 25 AND forest_percent < 50 THEN '25-50%'
      WHEN forest_percent >= 50 AND forest_percent < 75 THEN '50-75%'
      ELSE '75-100%'
    END AS quartile
  FROM forestation
  WHERE year = 2016 AND forest_percent IS NOT NULL
)
SELECT
  country_name,
  region,
  ROUND(CAST(forest_percent AS numeric) ,2)
FROM quartiles
WHERE quartile = '75-100%'
ORDER BY forest_percent desc;


