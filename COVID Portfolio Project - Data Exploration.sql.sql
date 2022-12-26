/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT *
FROM PortfolioProject1.coviddeaths
WHERE continent is not null
ORDER BY 3,4;

-- SELECT *
-- FROM PortfolioProject1.covidvaccinations
-- WHERE continent is not null
-- ORDER BY 3,4;

-- Select Data that we are going to be starting with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.coviddeaths
WHERE continent is not null
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1.coviddeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject1.coviddeaths
-- WHERE location like '%states%'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population 
SELECT location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject1.coviddeaths
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

-- Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject1.coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject1.coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, 
	SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1.coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2


-- SELECT *
-- FROM PortfolioProject1.coviddeaths dea
-- JOIN PortfolioProject1.covidvaccinations vac
-- 	ON dea.location = vac.location
--     and dea.date = vac.date
 
 
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.coviddeaths dea
JOIN PortfolioProject1.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.coviddeaths dea
JOIN PortfolioProject1.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists PercentPopulationVaccinated
USE PortfolioProject1;

CREATE TABLE PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated

-- -- Creating View to store for later visualizations
CREATE VIEW PercentPopulationVaccinated 
AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1.coviddeaths dea
JOIN PortfolioProject1.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null;
-- ORDER BY 2,3

