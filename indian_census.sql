-- No of Records in Dataset
SELECT COUNT(*) FROM data1
SELECT COUNT(*) FROM data2

-- Dataset for Uttar Pradesh 
SELECT *
FROM data1
WHERE State IN('Uttar Pradesh') 
ORDER BY District

-- Total population of India
SELECT SUM(Population) AS 'Total Population of India'
FROM data2

-- Average Growth of country
SELECT AVG(Growth)*100 AS 'Average Growth'
FROM data1 

-- Average growth of State
SELECT State,ROUND(( AVG(Growth)*100),2) AS Average_growth
FROM data1 
GROUP BY State

-- Average sex ratio
SELECT State, ROUND(AVG(Sex_Ratio),0) AS average_sexratio
FROM data1 
GROUP BY State
ORDER BY average_sexratio DESC

-- Average Literacy Ratio
SELECT State, ROUND(AVG(Literacy),2) AS Avg_literacy_ratio
FROM data1 
GROUP BY State
ORDER BY Avg_literacy_ratio DESC

-- States with literacy ratio greater than 90
SELECT State, ROUND(AVG(Literacy),2) AS Avg_literacy_ratio
FROM data1 
GROUP BY State
HAVING ROUND(AVG(Literacy),2)>90

-- TOP 3 states with highest growth ratio
SELECT State,ROUND(( AVG(Growth)*100),2) AS Average_growth
FROM data1 
GROUP BY State
ORDER BY Average_growth DESC LIMIT 3

-- Bottom 3 states showing lowest lowest sex ratio
SELECT State, ROUND(AVG(Sex_Ratio),0) AS average_sexratio
FROM data1 
GROUP BY State
ORDER BY average_sexratio LIMIT 3

-- TOP AND BOTTOM 3 STATES ACT LITERACY RATE
(SELECT State,ROUND(AVG(Literacy),2) AS Avg_literacy_ratio
FROM data1 
GROUP BY State
ORDER BY Avg_literacy_ratio DESC LIMIT 3)
UNION
(SELECT State,ROUND(AVG(Literacy),2) AS Avg_literacy_ratio
FROM data1 
GROUP BY State
ORDER BY Avg_literacy_ratio LIMIT 3)

-- States starting with letter'A'
SELECT DISTINCT State
FROM data1
WHERE State LIKE 'A%'

-- MALE AND FEMALE POPULATION
SELECT c.District,c.State,ROUND(c.Population/(c.gender_ratio+1),0)AS 'Male Population',ROUND((c.Population-(c.Population/(c.gender_ratio+1))),0) AS 'Female Population'
FROM ( SELECT data1.District,data1.State,Growth,Sex_Ratio/1000 AS gender_ratio,Literacy,Area_km2,Population
		FROM data1
        JOIN data2 USING(District) ) AS c

-- MALE AND FEMALE POPULATION A.C.T STATES
SELECT d.State,SUM(d.Male_Population) AS Males,SUM(d.Female_Population) AS Females FROM(
SELECT c.District,c.State,ROUND(c.Population/(c.gender_ratio+1),0) AS Male_Population,ROUND((c.Population-(c.Population/(c.gender_ratio+1))),0) AS Female_Population
FROM ( SELECT data1.District,data1.State,Growth,Sex_Ratio/1000 AS gender_ratio,Literacy,Area_km2,Population
		FROM data1
        JOIN data2 USING(District) ) AS c) AS d
GROUP BY d.State 

-- TOTAL LITERACY AND ILLITERATE POPULATION BY DISTRICT
SELECT e.District,e.State,ROUND(e.Literacy_ratio*e.Population,0) AS Literate_Population,ROUND(((1-e.Literacy_ratio)*e.Population),0)AS Illiterate_Population FROM
(SELECT data1.District,data1.State,ROUND(Literacy/100,2) AS Literacy_ratio,Population
		FROM data1
        JOIN data2 USING(District)) AS e

        
-- -- TOTAL LITERACY AND ILLITERATE POPULATION BY STATE
SELECT f.State,SUM(f.Literate_Population) AS Literate,SUM(f.Illiterate_Population) AS Illiterate FROM (
SELECT e.District,e.State,ROUND(e.Literacy_ratio*e.Population,0) AS Literate_Population,ROUND(((1-e.Literacy_ratio)*e.Population),0)AS Illiterate_Population FROM
(SELECT data1.District,data1.State,ROUND(Literacy/100,2) AS Literacy_ratio,Population
		FROM data1
        JOIN data2 USING(District)) AS e) AS f
GROUP BY f.State   

-- PREVIOUS CENSUS POPULATION 
SELECT a.District,a.State,ROUND(a.Population/(1+a.Growth),0) AS Previous_census_population,a.Population AS Current_census_population FROM (    
SELECT data1.District,data1.State,Growth,Population
		FROM data1
        JOIN data2 USING(District)) AS a

-- TOTAL POPULATION OF COUNTRY IN PREVIOUS AND CURRENT CENSUS
SELECT SUM(m.Total_population_in_pevious_census) AS Previous_total_population ,SUM(m.Total_population_current_census) AS Current_total_population  FROM(
SELECT b.State,SUM(b.Previous_census_population) AS Total_population_in_pevious_census,SUM(b.Current_census_population) AS Total_population_current_census FROM(
SELECT a.District,a.State,ROUND(a.Population/(1+a.Growth),0) AS Previous_census_population,a.Population AS Current_census_population FROM (    
SELECT data1.District,data1.State,Growth,Population
		FROM data1
        JOIN data2 USING(District)) AS a) AS b    
GROUP BY b.State ) AS m 

-- POPULATION VS AREA
SELECT q.*,r.* FROM(

SELECT '1' AS keyy,n.* FROM(
SELECT SUM(m.Total_population_in_pevious_census) AS Previous_total_population ,SUM(m.Total_population_current_census) AS Current_total_population  FROM(
SELECT b.State,SUM(b.Previous_census_population) AS Total_population_in_pevious_census,SUM(b.Current_census_population) AS Total_population_current_census FROM(
SELECT a.District,a.State,ROUND(a.Population/(1+a.Growth),0) AS Previous_census_population,a.Population AS Current_census_population FROM (    
SELECT data1.District,data1.State,Growth,Population
		FROM data1
        JOIN data2 USING(District)) AS a) AS b    
GROUP BY b.State ) AS m) AS n) AS q JOIN(
 
 SELECT '1' AS keyy,m.* FROM(
 SELECT SUM(Area_km2) AS Total_Area
 FROM data2) AS m) AS r ON q.keyy=r.keyy
 
 -- SHOW AREA PER UNIT POPULATION
 SELECT g.Total_Area/g.Previous_total_population AS Previous_Area_fraction,g.Total_Area/g.Current_total_population AS Current_Area_fraction FROM (
 SELECT q.*,r.Total_Area FROM(

SELECT '1' AS keyy,n.* FROM(
SELECT SUM(m.Total_population_in_pevious_census) AS Previous_total_population ,SUM(m.Total_population_current_census) AS Current_total_population  FROM(
SELECT b.State,SUM(b.Previous_census_population) AS Total_population_in_pevious_census,SUM(b.Current_census_population) AS Total_population_current_census FROM(
SELECT a.District,a.State,ROUND(a.Population/(1+a.Growth),0) AS Previous_census_population,a.Population AS Current_census_population FROM (    
SELECT data1.District,data1.State,Growth,Population
		FROM data1
        JOIN data2 USING(District)) AS a) AS b    
GROUP BY b.State ) AS m) AS n) AS q JOIN(
 
 SELECT '1' AS keyy,m.* FROM(
 SELECT SUM(Area_km2) AS Total_Area
 FROM data2) AS m) AS r ON q.keyy=r.keyy) AS g
 
 -- TOP 3 DISTRICTS FROM EACH STATE WITH HIGHEST LITERACY RATE
 SELECT a.* FROM(
 SELECT District,State,Literacy,rank() over(partition by State ORDER BY Literacy DESC) AS ranking FROM data1) AS a
 WHERE a.ranking IN (1,2,3)
        



