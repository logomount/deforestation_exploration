/* a. What was the total forest area (in sq km) of the world in 1990?
Please keep in mind that you can use the country record denoted as “World" in the region table.
Answer: 41282695 sq km */

SELECT
      f.country_name,
      ROUND(f.forest_area_sqkm::NUMERIC, 2) AS forest_area_sqkm,
      f.year
FROM forest_area AS f
WHERE f.country_name = 'World' AND f.year = 1990;

/* b. What was the total forest area (in sq km) of the world in 2016?
Please keep in mind that you can use the country record in the table is denoted as “World.”
Answer: 39958246 sq km */

SELECT
      f.country_name,
      ROUND(f.forest_area_sqkm::NUMERIC, 2) AS forest_area_sqkm,
      f.year
FROM forest_area AS f
WHERE f.country_name = 'World' AND f.year = 2016;

/* c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
Answer: 1324449 sq km */

SELECT
      country_name,
      ROUND((LEAD(forest_area_sqkm) OVER (ORDER BY forest_area_sqkm) - forest_area_sqkm)::NUMERIC, 2) AS forest_area_loss_sqkm
FROM (SELECT
            country_name,
            forest_area_sqkm
      FROM forest_area
      WHERE country_name = 'World' AND year = 2016 OR country_name = 'World' AND year = 1990
) sub LIMIT 1

/* d. What was the percent change in forest area of the world between 1990 and 2016?
Answer: 3 % */

SELECT
      country_name,
      ROUND(((LEAD(forest_area_sqkm) OVER (ORDER BY forest_area_sqkm) - forest_area_sqkm)/forest_area_sqkm*100)::NUMERIC, 2) AS forest_area_loss_percent
FROM (SELECT
            country_name,
            forest_area_sqkm
      FROM forest_area
      WHERE country_name = 'World' AND year = 2016 OR country_name = 'World' AND year = 1990
) sub LIMIT 1

/*EDIT*/

SELECT
      country_name,
      ROUND(((LAG(forest_area_sqkm) OVER (ORDER BY forest_area_sqkm) - forest_area_sqkm)/forest_area_sqkm*100)::NUMERIC, 2) AS forest_area_loss_percent
FROM (SELECT
            country_name,
            forest_area_sqkm
      FROM forest_area
      WHERE country_name = 'World' AND year = 2016 OR country_name = 'World' AND year = 1990
) sub
ORDER BY 2 ASC LIMIT 1

/* e. If you compare the amount of forest area lost between 1990 and 2016, to which
country's total area in 2016 is it closest to?
Answer: Peru, 1279950.568251 sq km */
SELECT
      country_name,
      ROUND((total_area_sq_mi * 2.59)::NUMERIC, 2) as total_area_sq_km
FROM land_area
WHERE total_area_sq_mi * 2.59 <= (
  SELECT LEAD(forest_area_sqkm) OVER (ORDER BY forest_area_sqkm) - forest_area_sqkm AS forest_area_loss_sqkm
  FROM (SELECT
              country_name, year,
              forest_area_sqkm
        FROM forest_area
        WHERE country_name = 'World' AND year = 2016 OR country_name = 'World' AND year = 1990
  ) sub LIMIT 1)
ORDER BY 2 DESC LIMIT 1;
