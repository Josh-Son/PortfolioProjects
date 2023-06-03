/* COVID-19 Exploratory Data Analysis in SQL Queries */

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Selecting Data that we will start looking at first
SELECT [location], [date], total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPerc
FROM PortfolioProject..CovidDeaths
WHERE [location] LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with COVID
Select [location], [date], population, total_cases, (total_cases/population)*100 AS InfectedPerc
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT [location], population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPerc
FROM PortfolioProject..CovidDeaths
GROUP BY [location], population
ORDER BY InfectedPerc DESC

-- Countries with Highest Death Count per Population
SELECT [location], MAX(CONVERT(INT,total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC



-- Looking at the data by each Contintent
-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPerc
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY [date]
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one COVID Vaccine
SELECT 
    d.continent, 
    d.[location], 
    d.[date], 
    d.population,v.new_vaccinations,
    SUM(CONVERT(INT,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS VaccinatedRolling
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
    ON d.[location]=v.[location] and d.[date]=v.[date]
WHERE d.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (Continent, location, date, population, new_vaccinations, VaccinatedRolling)
AS
(
SELECT 
    d.continent, 
    d.[location], 
    d.[date], 
    d.population,v.new_vaccinations,
    SUM(CONVERT(INT,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS VaccinatedRolling
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
    ON d.[location]=v.[location] and d.[date]=v.[date]
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (VaccinatedRolling/population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition BY in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
VaccinatedRolling NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
    d.continent, 
    d.[location], 
    d.[date], 
    d.population,v.new_vaccinations,
    SUM(CONVERT(INT,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS VaccinatedRolling
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
    ON d.[location]=v.[location] and d.[date]=v.[date]
--WHERE d.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (VaccinatedRolling/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    d.continent, 
    d.[location], 
    d.[date], 
    d.population,v.new_vaccinations,
    SUM(CONVERT(INT,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS VaccinatedRolling
    -- (VaccinatedRolling/population)*100
FROM PortfolioProject..CovidDeaths AS d
JOIN PortfolioProject..CovidVaccinations AS v
    ON d.[location]=v.[location] and d.[date]=v.[date]
WHERE d.continent IS NOT NULL
