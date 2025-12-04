--sales by region

with cte as (select TerritoryID, sum(TotalDue) as total_sales from sales.SalesOrderHeader
where OrderDate between '2013-07-01' and '2014-06-30'
group by TerritoryID)

select cte.TerritoryID,Name, total_sales,SalesYTD,SalesLastYear from cte
inner join sales.SalesTerritory as t
on t.TerritoryID = cte.TerritoryID
order by total_sales desc

--Script for Sales by US Region 
SELECT Name AS RegionName, 
	   ROUND(SalesYTD, 2) AS Sales_YTD, 
	   ROUND(SalesLastYear, 2) AS Sales_LastYear
FROM Sales.SalesTerritory
WHERE CountryRegionCode = 'US'
ORDER BY Sales_YTD DESC

-- Script for Sales by Country  
WITH cte AS 
	(SELECT CountryRegionCode, 
			ROUND(SUM(SalesYTD), 2) AS Sales_YTD, 
			ROUND(SUM(SalesLastYear), 2) AS Sales_LastYear
	FROM Sales.SalesTerritory
	GROUP By CountryRegionCode)

SELECT Name AS CountryName, Sales_YTD, Sales_LastYear
FROM cte
INNER JOIN Person.CountryRegion AS c
ON c.CountryRegionCode = cte.CountryRegionCode
ORDER BY Sales_YTD + Sales_LastYear DESC

--anual leave and bonus
SELECT VacationHours AS annual_leave, Bonus, SalesQuota, ROUND(SalesYTD,2) AS SalesYTD, JobTitle
FROM HumanResources.Employee AS hre
INNER JOIN Sales.SalesPerson AS ssp
ON hre.BusinessEntityID = ssp.BusinessEntityID
ORDER BY annual_leave;

--Sick leave by job Group 
WITH cte AS (SELECT  cASt(isnull(OrganizationLevel,0) AS INT) AS OrganizationLevel,jobtitle,SickLeaveHours,
CASE	WHEN OrganizationLevel IS NULL OR OrganizationLevel = 0 THEN 'CEO'
        WHEN OrganizationLevel = 1 THEN 'Directors'
		WHEN OrganizationLevel = 2 AND JobTitle LIKE '%Specialist%' THEN 'Specialists'
		WHEN OrganizationLevel = 2 THEN 'Upper Management'
		WHEN OrganizationLevel = 3 AND JobTitle LIKE '%Supervisor%' THEN 'Supervisors'
		WHEN OrganizationLevel = 3 AND JobTitle LIKE '%Sales%' THEN 'Sales Rep.'
		WHEN OrganizationLevel = 3 THEN 'Senior Roles'
		WHEN OrganizationLevel = 4 AND JobTitle LIKE '%Technician%' THEN 'Technicians'
		WHEN OrganizationLevel = 4 THEN 'Entry Roles'		
		ELSE jobtitle END AS Job_Group
FROM HumanResources.Employee)

SELECT avg(SickLeaveHours) AS Sick_Leave,stdev(SickLeaveHours) AS Deviation,Job_Group,OrganizationLevel,count(*) FROM cte
GROUP BY Job_Group,OrganizationLevel
ORDER BY OrganizationLevel DESC

--Sick leave by job title
SELECT replace(replace(replace(JobTitle,'Production',''),'Representative','Rep.'),' - ',' ') as Title, avg(SickLeaveHours) AS Average_SickLeave, count(*) AS Num_Employees, OrganizationLevel
FROM HumanResources.Employee
GROUP BY jobtitle, OrganizationLevel
ORDER BY count(*) desc

--average revenue 5 year group 
WITH cte AS (SELECT  CASE WHEN YEAROPENED BETWEEN 1970 AND 1974 THEN 1970
        WHEN YEAROPENED BETWEEN 1975 AND 1979 THEN 1975
        WHEN YEAROPENED BETWEEN 1980 AND 1984 THEN 1980
        WHEN YEAROPENED BETWEEN 1985 AND 1989 THEN 1985
        WHEN YEAROPENED BETWEEN 1990 AND 1994 THEN 1990
        WHEN YEAROPENED BETWEEN 1995 AND 1999 THEN 1995
        ELSE 2000
        END AS year_group, 
AnnualRevenue
FROM Sales.vStoreWithDemographics)

SELECT year_group, avg(AnnualRevenue) AS avg_rev, count(*) AS count
FROM cte
GROUP BY year_group

-- store survey duration and revenue
SELECT YearOpened, 2004 - YearOpened AS Trading_Duration, BusinessType, Specialty, SquareFeet , AnnualRevenue 
FROM Sales.vStoreWithDemographics
ORDER BY SquareFeet DESC

--store size number of employee and revenue
SELECT SquareFeet, NumberEmployees, AnnualRevenue
FROM Sales.vStoreWithDemographics
ORDER BY squarefeet DESC
