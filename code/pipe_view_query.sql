SELECT DISTINCT year, election, jurisdiction, position, precinct, geometry
FROM precinct_result
INNER JOIN precinct_geometry_2016
USING(precinct)
WHERE year = 2021

UNION

SELECT DISTINCT year, election, jurisdiction, position, precinct, geometry 
FROM precinct_result
INNER JOIN precinct_geometry_2022
USING(precinct)
WHERE year = 2023;