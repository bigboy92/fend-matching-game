create database forestsdb;


use forestsdb;
-- ========================================
-- 0. CLEAN UP OLD STRUCTURE (IF ANY)
-- ========================================
DROP VIEW IF EXISTS forestation;
DROP TABLE IF EXISTS forest_area;
DROP TABLE IF EXISTS land_area;
DROP TABLE IF EXISTS regions;

-- ========================================
-- 1. CREATE TABLES
-- ========================================
CREATE TABLE forest_area (
    country_code VARCHAR(10),
    country_name VARCHAR(100),
    year INT,
    forest_area_sqkm FLOAT
);

CREATE TABLE land_area (
    country_code VARCHAR(10),
    year INT,
    total_area_sq_mi FLOAT
);

CREATE TABLE regions (
    country_code VARCHAR(10),
    region VARCHAR(100),
    income_group VARCHAR(100)
);

-- ========================================
-- 2. INSERT SAMPLE DATA
-- ========================================
INSERT INTO forest_area VALUES
('WLD', 'World', 1990, 42000000),
('WLD', 'World', 2016, 39000000),
('BRA', 'Brazil', 1990, 5200000),
('BRA', 'Brazil', 2016, 4900000),
('FIN', 'Finland', 1990, 210000),
('FIN', 'Finland', 2016, 230000),
('IND', 'India', 1990, 640000),
('IND', 'India', 2016, 710000),
('IDN', 'Indonesia', 1990, 1180000),
('IDN', 'Indonesia', 2016, 910000);

INSERT INTO land_area VALUES
('WLD', 1990, 51000000),
('WLD', 2016, 51000000),
('BRA', 1990, 3200000),
('BRA', 2016, 3200000),
('FIN', 1990, 150000),
('FIN', 2016, 150000),
('IND', 1990, 1200000),
('IND', 2016, 1200000),
('IDN', 1990, 735000),
('IDN', 2016, 735000);

INSERT INTO regions VALUES
('WLD', 'World', 'All income levels'),
('BRA', 'South America', 'Upper middle income'),
('FIN', 'Europe & Central Asia', 'High income'),
('IND', 'South Asia', 'Lower middle income'),
('IDN', 'East Asia & Pacific', 'Lower middle income');

-- ========================================
-- 3. CREATE VIEW
-- ========================================
CREATE VIEW forestation AS
SELECT 
    fa.country_code,
    fa.country_name,
    fa.year,
    fa.forest_area_sqkm,
    la.total_area_sq_mi,
    r.region,
    r.income_group,
    CASE 
        WHEN la.total_area_sq_mi IS NOT NULL 
             AND la.total_area_sq_mi > 0 
             AND fa.forest_area_sqkm IS NOT NULL THEN 
            (fa.forest_area_sqkm / (la.total_area_sq_mi * 2.59)) * 100
        ELSE NULL 
    END AS forest_percent
FROM forest_area fa
INNER JOIN land_area la 
    ON fa.country_code = la.country_code 
    AND fa.year = la.year
INNER JOIN regions r 
    ON fa.country_code = r.country_code;
    
    select * from forest_area;
    select * from land_area;
	select * from regions;