CREATE VIEW forestation AS
SELECT
      r.region,
      f.year,
      SUM(f.forest_area_sqkm) AS forest_area_sqkm,
      (SUM(f.forest_area_sqkm)/(SUM(l.total_area_sq_mi)*2.59)*100) AS percent
FROM regions AS r
JOIN forest_area AS f
ON r.country_code = f.country_code
JOIN land_area AS l
ON r.country_code = l.country_code
WHERE f.year = 2016 AND l.year = 2016 OR f.year = 1990 AND l.year = 1990
GROUP BY 1, 2

/*a. What was the percent forest of the entire world in 2016? Answer: World, 31.39 %
Which region had the HIGHEST percent forest in 2016, Answer: Latin America & Caribbean, 46.18 %
and which had the LOWEST, to 2 decimal places? Answer: Middle East & North Africa, 2.07 % */

SELECT
      region,
      year,
      ROUND(percent::NUMERIC, 2) AS forest_area_percent
FROM forestation
WHERE year = 2016 OR year =  1990

SELECT
      region,
      year,
      ROUND(percent::NUMERIC, 2) AS forest_area_percent
FROM forestation
WHERE year = 2016 AND region = 'World'

SELECT
      region,
      year,
      ROUND((LEAD(percent) OVER (ORDER BY percent) - percent)::NUMERIC, 2) AS forestation_change
FROM forestation
WHERE region = 'World'

SELECT
      region,
      year,
      ROUND(MAX(percent)::NUMERIC, 2) AS highest_forestation
FROM forestation
WHERE year = 2016
GROUP BY 1, 2
ORDER BY 3 DESC LIMIT 1

SELECT
      region,
      year,
      ROUND(MIN(percent)::NUMERIC) AS lowest_forestation
FROM forestation
WHERE year = 2016
GROUP BY 1, 2
ORDER BY 3 LIMIT 1

/* b. What was the percent forest of the entire world in 1990? Answer: World, 32.43 %
Which region had the HIGHEST percent forest in 1990, Answer: Latin America & Caribbean, 51.05 %
and which had the LOWEST, to 2 decimal places? Answer: Middle East & North Africa, 1.78 % */

SELECT
      region,
      year,
      ROUND(percent::NUMERIC, 2) AS forestation
FROM forestation
WHERE year = 1990 AND region = 'World'

SELECT
      region,
      year,
      ROUND(MAX(percent)::NUMERIC, 2) AS highest_forestation
FROM forestation
WHERE year = 1990
GROUP BY 1,2
ORDER BY 3 DESC LIMIT 1

SELECT
      region,
      year,
      ROUND(MIN(percent)::NUMERIC, 2) AS lowest_forestation
FROM forestation
WHERE year = 1990
GROUP BY 1,2
ORDER BY 3 LIMIT 1

/* c. Based on the table you created, which regions of the world DECREASED
in forest area from 1990 to 2016? Answer:  */

SELECT
      region,
      year,
      percent,
      (SELECT ROUND((LEAD(percent) OVER (ORDER BY percent) - percent)::NUMERIC, 2) AS forestation_change
  FROM forestation
  WHERE region = f.region
  LIMIT 1
)
FROM forestation AS f
WHERE (
  SELECT
        ROUND((LEAD(percent) OVER (ORDER BY percent) - percent)::NUMERIC, 2) AS forestation_change
  FROM forestation
  WHERE region = f.region
	LIMIT 1
) > 0 AND year = 2016

SELECT
      region,
      year,
      percentage,
      (SELECT ROUND((LEAD(percentage) OVER (ORDER BY year) - percentage)::NUMERIC, 2) AS forestation_change
      FROM forestation
      WHERE region = f.region
      LIMIT 1
)
FROM forestation AS f
ORDER BY 1, 2
