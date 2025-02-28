/* Erstellen der VIEW

CREATE VIEW	forestation AS

		SELECT	fa.country_code AS cc,
				fa.country_name AS cn,
				r.region,
				r.income_group,
				fa.year,
				fa.forest_area_sqkm,
				(la.total_area_sq_mi*2.59) AS land_area_sqkm,
				(fa.forest_area_sqkm/la.total_area_sq_mi*2.59)*100 AS forest_land_perc
				
		FROM	forest_area fa
		
		JOIN	land_area la ON fa.country_code=la.country_code AND fa.year=la.year
		JOIN	regions r ON fa.country_code=r.country_code
		
		WHERE	fa.forest_area_sqkm IS NOT NULL
			AND	la.total_area_sq_mi IS NOT NULL
			
*/

/* 1. globale Situation

1.a, b, c, d

WITH forest_area_1990_2016 AS (
		SELECT	cn,
				year,
				forest_area_sqkm
		FROM	forestation
		WHERE	cn='World' AND year in (1990,2016)
		)

SELECT	SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) AS forest_area_1990, -- Waldfläche 1990
		
		SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) AS forest_area_2016, -- Waldfläche 2016
		
		SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END)
		- SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) AS forest_area_diff_1990_2016, -- Waldflächendifferenz zwischen 1990 und 2016
		
		((SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END) - SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END))
		/(SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END)) * 100) AS forest_area_perc_1990_2016 -- prozentuale Veränderung 1990 und 2016
				
FROM	forest_area_1990_2016

1.c -- mit self join

WITH forest_area_1990_2016 AS (
		SELECT	cn,
				year,
				forest_area_sqkm
		FROM	forestation
		WHERE	cn='World' AND year in (1990,2016)
		)

SELECT	fa2016.forest_area_sqkm-fa1990.forest_area_sqkm AS forest_area_diff_1990_2016 -- Waldflächendifferenz zwischen 1990 und 2016
				
FROM	forest_area_1990_2016 fa1990
JOIN	forest_area_1990_2016 fa2016 ON fa1990.cn=fa2016.cn


1.e

WITH forest_area_1990_2016 AS (
		SELECT	ABS(SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END)
				- SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END)) AS forest_area_diff_1990_2016 -- Waldflächendifferenz zwischen 1990 und 2016
		
		FROM	forestation
		WHERE	cn='World' AND year in (1990,2016)
		)

SELECT		cn,
			land_area_sqkm
FROM		forestation
WHERE		land_area_sqkm < (SELECT forest_area_diff_1990_2016 FROM forest_area_1990_2016)
ORDER BY	land_area_sqkm DESC
LIMIT		1

*/

/* 2. regionaler Ausblick

WITH regional AS (
	SELECT		region,
				SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END) AS forest_area_1990,
				SUM(CASE WHEN year=1990 THEN land_area_sqkm ELSE 0 END)  AS  land_area_1990,
				SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END)  AS  forest_area_2016,
				SUM(CASE WHEN year=2016 THEN land_area_sqkm ELSE 0 END)  AS  land_area_2016,
				(SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE 0 END)/SUM(CASE WHEN year=1990 THEN land_area_sqkm ELSE 0 END)*100) AS perc_forest_area_1990,
				(SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE 0 END)/SUM(CASE WHEN year=2016 THEN land_area_sqkm ELSE 0 END)*100) AS perc_forest_area_2016
	FROM 		forestation
	WHERE		year IN (1990,2016)
	GROUP BY	1
	)

2.a

SELECT		region,
			perc_forest_area_2016
FROM		regional
WHERE		region='World'

SELECT		region,
			perc_forest_area_2016
FROM		regional
ORDER BY	perc_forest_area_2016 DESC -- für lowest Ausgabe ASC
LIMIT		1

2.b

SELECT		region,
			perc_forest_area_1990
FROM		regional
WHERE		region='World'

SELECT		region,
			perc_forest_area_1990
FROM		regional
ORDER BY	perc_forest_area_1990 DESC -- für lowest Ausgabe ASC
LIMIT		1

2.c

SELECT		region,
			perc_forest_area_1990,
			perc_forest_area_2016,
			(perc_forest_area_2016-perc_forest_area_1990) AS perc_forest_area
FROM		regional
ORDER BY	perc_forest_area ASC

*/

/* 3. Details auf Ländereben

3.a & b

WITH forest_area AS (
	SELECT		cn,
				region,
				SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END) AS forest_area_1990,
				SUM(CASE WHEN year=1990 THEN land_area_sqkm ELSE NULL END)  AS  land_area_1990,
				SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE NULL END)  AS  forest_area_2016,
				SUM(CASE WHEN year=2016 THEN land_area_sqkm ELSE NULL END)  AS  land_area_2016
	FROM 		forestation
	WHERE		year IN (1990,2016)
	GROUP BY	cn, region
	HAVING		SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END)	IS NOT NULL
			AND	SUM(CASE WHEN year=1990 THEN land_area_sqkm ELSE NULL END)		IS NOT NULL
			AND	SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE NULL END)	IS NOT NULL
			AND	SUM(CASE WHEN year=2016 THEN land_area_sqkm ELSE NULL END)		IS NOT NULL
	)

SELECT		cn,
			region,
			forest_area_1990,
			forest_area_2016,
			(forest_area_2016-forest_area_1990) AS forest_descrease_1990_2016,
			((forest_area_2016-forest_area_1990)/forest_area_1990)*100 AS forest_perc_1990_2016
FROM		forest_area
WHERE		cn <> 'World' 
ORDER BY	forest_descrease_1990_2016 DESC -- ASC für Entwaldung
LIMIT 5

SELECT		cn,
			region,
			forest_area_1990,
			forest_area_2016,
			(forest_area_2016-forest_area_1990) AS forest_descrease_1990_2016,
			((forest_area_2016-forest_area_1990)/forest_area_1990)*100 AS forest_perc_1990_2016
FROM		forest_area
WHERE		cn <> 'World' 
ORDER BY	forest_perc_1990_2016 DESC -- ASC für Entwaldung
LIMIT 5


---beide Anfragen miteinander vergleichen ein Wert ausspielen

WITH forest_area AS (
	SELECT		cn,
				region,
				SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END) AS forest_area_1990,
				SUM(CASE WHEN year=1990 THEN land_area_sqkm ELSE NULL END)  AS  land_area_1990,
				SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE NULL END)  AS  forest_area_2016,
				SUM(CASE WHEN year=2016 THEN land_area_sqkm ELSE NULL END)  AS  land_area_2016
	FROM 		forestation
	WHERE		year IN (1990,2016)
	GROUP BY	cn, region
	HAVING		SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END)	IS NOT NULL
			AND	SUM(CASE WHEN year=1990 THEN land_area_sqkm ELSE NULL END)		IS NOT NULL
			AND	SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE NULL END)	IS NOT NULL
			AND	SUM(CASE WHEN year=2016 THEN land_area_sqkm ELSE NULL END)		IS NOT NULL
	),

total_forest_descrease_1990_2016 AS (
	SELECT		cn,
				region,
				forest_area_1990,
				forest_area_2016,
				(forest_area_2016-forest_area_1990) AS forest_descrease_1990_2016,
				((forest_area_2016-forest_area_1990)/forest_area_1990)*100 AS forest_perc_1990_2016
	FROM		forest_area
	WHERE		cn <> 'World'
	ORDER BY	forest_descrease_1990_2016 ASC -- ASC für Entwaldung
	LIMIT 5
	),

total_forest_perc_1990_2016 AS (
	SELECT		cn,
				region,
				forest_area_1990,
				forest_area_2016,
				(forest_area_2016-forest_area_1990) AS forest_descrease_1990_2016,
				((forest_area_2016-forest_area_1990)/forest_area_1990)*100 AS forest_perc_1990_2016
	FROM		total_forest_descrease_1990_2016
	WHERE		cn <> 'World' 
	ORDER BY	forest_perc_1990_2016 ASC -- ASC für Entwaldung
	LIMIT 1
	)

SELECT 		*
FROM		total_forest_perc_1990_2016

-- 3.c

WITH forest_area AS (
	SELECT		cn,
				region,
				SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END) AS forest_area_1990,
				SUM(CASE WHEN year=1990 THEN land_area_sqkm ELSE NULL END)  AS  land_area_1990,
				SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE NULL END)  AS  forest_area_2016,
				SUM(CASE WHEN year=2016 THEN land_area_sqkm ELSE NULL END)  AS  land_area_2016
	FROM 		forestation
	WHERE		year IN (1990,2016)
	GROUP BY	cn, region
	HAVING		SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END)	IS NOT NULL
			AND	SUM(CASE WHEN year=1990 THEN land_area_sqkm ELSE NULL END)		IS NOT NULL
			AND	SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE NULL END)	IS NOT NULL
			AND	SUM(CASE WHEN year=2016 THEN land_area_sqkm ELSE NULL END)		IS NOT NULL
	),

total_forest_perc AS (
	SELECT	cn,
			region,
			forest_area_1990,
			forest_area_2016,
			forest_area_1990/land_area_1990*100 AS forest_perc_1990,
			forest_area_2016/land_area_2016*100 AS forest_perc_2016,
			(forest_area_2016/land_area_2016*100) - (forest_area_1990/land_area_1990*100) AS perc_change
	FROM	forest_area
	WHERE	cn <> 'World'
	),

percentiles AS (
    SELECT 	forest_perc_2016,
			PERCENT_RANK() OVER (ORDER BY forest_perc_2016) AS percentile
    FROM 	total_forest_perc
	),
	
quartile_limits AS (
    SELECT 	MIN(forest_perc_2016) AS min_val,
			MAX(CASE WHEN percentile <= 0.25 THEN forest_perc_2016 END) AS q1,
			MAX(CASE WHEN percentile <= 0.50 THEN forest_perc_2016 END) AS q2,
			MAX(CASE WHEN percentile <= 0.75 THEN forest_perc_2016 END) AS q3,
			MAX(forest_perc_2016) AS max_val
    FROM 	percentiles
	),
	
quartile_assignment AS (
    SELECT	tfp.*,
			CASE
               WHEN tfp.forest_perc_2016 <= ql.q1 THEN 1
               WHEN tfp.forest_perc_2016 <= ql.q2 THEN 2
               WHEN tfp.forest_perc_2016 <= ql.q3 THEN 3
               ELSE 4
			END AS quartile
    FROM	total_forest_perc tfp, quartile_limits ql
	)
	
SELECT 		quartile, 
			COUNT(*) AS country_count
FROM		quartile_assignment
GROUP BY	quartile
ORDER BY 	country_count DESC;

SELECT 		quartile, 
			cn,
			forest_perc_2016
FROM 		quartile_assignment
WHERE		quartile=4
ORDER BY 	forest_perc_2016 DESC;




