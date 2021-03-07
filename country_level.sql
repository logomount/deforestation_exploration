CREATE VIEW country_forestation AS
SELECT
      f.country_name,
      f.country_code,
      r.region, f.year,
      f.forest_area_sqkm,
      ((f.forest_area_sqkm/(l.total_area_sq_mi*2.59))*100) AS forestation_percent
FROM forest_area AS f
JOIN land_area AS l
ON f.country_code = l.country_code
LEFT JOIN regions AS r
ON r.country_code = l.country_code
WHERE f.year = 2016 AND l.year = 2016 OR f.year = 1990 AND l.year = 1990

WITH forestation_2016 AS (
    SELECT
          country_name,
          country_code,
          region,
          year,
          ROUND(forest_area_sqkm::NUMERIC, 2) AS forest_area_sqkm,
          ROUND(forestation_percent::NUMERIC, 2) AS forestation_percent
    FROM country_forestation
    WHERE year = 2016
), forestation_1990 AS (
    SELECT
          country_name,
          country_code,
          region, year,
          ROUND(forest_area_sqkm::NUMERIC, 2) AS forest_area_sqkm,
          ROUND(forestation_percent::NUMERIC, 2) AS forestation_percent
    FROM country_forestation
    WHERE year = 1990
)
/*INCREASE*/
SELECT
      forestation_2016.country_name,
      forestation_2016.region,
      forestation_2016.forest_area_sqkm - forestation_1990.forest_area_sqkm AS forest_area_change_sqkm
FROM forestation_2016
JOIN forestation_1990
ON forestation_2016.country_code = forestation_1990.country_code
WHERE forestation_2016.country_code != 'WLD' AND forestation_1990.forest_area_sqkm IS NOT NULL
AND forestation_2016.forest_area_sqkm IS NOT NULL
ORDER BY 3 DESC LIMIT 5

SELECT
      forestation_2016.country_name,
      forestation_2016.region,
      ROUND((forestation_2016.forest_area_sqkm - forestation_1990.forest_area_sqkm)/forestation_1990.forest_area_sqkm*100::NUMERIC, 2) AS forest_area_change_percent
FROM forestation_2016
JOIN forestation_1990
ON forestation_2016.country_code = forestation_1990.country_code
WHERE forestation_2016.country_name != 'WLD' AND forestation_1990.forest_area_sqkm IS NOT NULL
AND forestation_2016.forest_area_sqkm IS NOT NULL
ORDER BY 3 DESC LIMIT 5

/*DECREASE*/

SELECT
      forestation_2016.country_name,
      forestation_2016.region,
      forestation_2016.forest_area_sqkm - forestation_1990.forest_area_sqkm AS forest_area_change_sqkm
FROM forestation_2016
JOIN forestation_1990
ON forestation_2016.country_code = forestation_1990.country_code
WHERE forestation_2016.country_code != 'WLD'
ORDER BY 3 ASC LIMIT 5

SELECT
      forestation_2016.country_name,
      forestation_2016.region,
      ROUND((forestation_2016.forest_area_sqkm - forestation_1990.forest_area_sqkm)/forestation_1990.forest_area_sqkm*100::NUMERIC, 2) AS forest_area_change_percent
FROM forestation_2016
JOIN forestation_1990
ON forestation_2016.country_code = forestation_1990.country_code
WHERE forestation_2016.country_name != 'WLD'
ORDER BY 3 ASC LIMIT 5

/*QUARTILES*/
SELECT
      COUNT(CASE WHEN forestation_percent < 25 THEN 1 ELSE NULL END) first_quartile,
      COUNT(CASE WHEN forestation_percent >= 25 AND forestation_percent < 50 THEN 2 ELSE NULL END) second_quartile,
      COUNT(CASE WHEN forestation_percent >= 50 AND forestation_percent < 75 THEN 3 ELSE NULL END) third_quartile,
      COUNT(CASE WHEN forestation_percent >= 75 AND forestation_percent <= 100 THEN 4 ELSE NULL END) fourth_quartile
FROM country_forestation
WHERE year = 2016

SELECT
      country_name,
      region,
      ROUND(forestation_percent::NUMERIC, 2) AS forestation_percent
FROM country_forestation
WHERE year = 2016 AND forestation_percent >= 75
ORDER BY 3 DESC


WITH forestion_quartiles AS (
  SELECT
        NTILE(4) OVER (ORDER BY forestation_percent) AS quartile,
        country_name,
        region,
        forestation_percent
  FROM country_forestation
  WHERE year = 2016 AND forestation_percent IS NOT NULL
  ORDER BY 1 DESC
)

SELECT
      quartile,
      COUNT(*)
FROM forestion_quartiles
GROUP BY 1
ORDER BY 1 DESC

SELECT
      country_name,
      region,
      forestation_percent
FROM forestion_quartiles
WHERE quartile = 1
