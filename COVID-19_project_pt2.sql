-- 1. 
-- Queries needed for tableau data visualization

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject .. CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Double check based on data provided

-- 2. 
-- Filter out locations that are not continents

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount

-- 3. 
-- Query infections rates based on population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected 
FROM PortfolioProject .. CovidDeaths
--WHERE continent is not null
Group by Location, population
ORDER BY PercentPopulationInfected desc

-- 4. 
-- Query infection rate based on date 

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected 
FROM PortfolioProject .. CovidDeaths
--WHERE continent is not null
Group by Location, population, date
ORDER BY PercentPopulationInfected desc

-- 5.

