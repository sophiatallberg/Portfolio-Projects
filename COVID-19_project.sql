SELECT * FROM PortfolioProject .. CovidDeaths
ORDER BY 3,4;

-- SELECT * FROM PortfolioProject .. CovidVaccinations
-- ORDER BY 3,4
-- SELECT data that I am going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject .. CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in specified country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage 
FROM PortfolioProject .. CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of the population aquired COVID-19

SELECT Location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected 
FROM PortfolioProject .. CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to popultion

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected 
FROM PortfolioProject .. CovidDeaths
WHERE continent is not null
Group by Location, population
ORDER BY PercentPopulationInfected desc

-- Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject .. CovidDeaths
WHERE continent is not null
Group by Location
ORDER BY TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject .. CovidDeaths
WHERE continent is null
Group by Location
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject .. CovidDeaths
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject .. CovidDeaths
WHERE continent is not null
Group by date
ORDER BY 1,2

-- Total cases worldwide including total death and the death percentage

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject .. CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location , dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject .. CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated) as ( 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location , dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject .. CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population) * 100 as PercentagePopulationVaccinated
FROM PopvsVac


--TEMP TABLE

Drop table if exists #PercentTableVaccinated
Create Table #PercentTableVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentTableVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location , dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject .. CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population) * 100 as PercentagePopulationVaccinated
FROM #PercentTableVaccinated

-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location , dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject .. CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT * FROM PercentPopulationVaccinated
