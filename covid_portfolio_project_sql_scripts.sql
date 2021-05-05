SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2 -- order by location and date



-- Looking at Total Cases vs Total Deaths

-- Shows likelihood of dying if you contract COVID-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent is not null
ORDER BY 1, 2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID-19

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CovidInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent is not null
ORDER BY 1, 2


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CovidInfectedPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY CovidInfectedPercentage DESC

-- Showing countries with Highest Death Count by Population



SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING DEATHS BY CONTINENT

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the continents with the Highest death count per population

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2



-- COVID Vaccinations

-- Looking at Total Populations vs Total Vaccinations

-- USE CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--CONVERT(int, vac.new_vaccinations)
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--CONVERT(int, vac.new_vaccinations)
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated