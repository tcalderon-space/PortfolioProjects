SELECT *
FROM [Project Portfolio]..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Project Portfolio]..CovidDeaths$
ORDER BY Location, date


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Project Portfolio]..CovidDeaths$
ORDER BY Location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
FROM [Project Portfolio]..CovidDeaths$
WHERE continent is not null
WHERE location like '%states%'
ORDER BY Location, date

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, 
MAX(total_cases/population)*100 as PercentPopulationInfected
FROM [Project Portfolio]..CovidDeaths$
WHERE continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Project Portfolio]..CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT




-- Showing continenets with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Project Portfolio]..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Project Portfolio]..CovidDeaths$
--Where location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--individual number
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Project Portfolio]..CovidDeaths$
--Where location like '%states%'
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
ORDER by dea.location, dea.Date) as RollingPeopleVaccinated --,
 --(RollingPeopleVaccinated/population)*100
FROM [Project Portfolio]..CovidDeaths$ dea
JOIN [Project Portfolio]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
 
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
ORDER by dea.location, dea.Date) as RollingPeopleVaccinated --,
 --(RollingPeopleVaccinated/population)*100
FROM [Project Portfolio]..CovidDeaths$ dea
JOIN [Project Portfolio]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location 
ORDER by dea.location, dea.Date) as RollingPeopleVaccinated --,
 --(RollingPeopleVaccinated/population)*100
FROM [Project Portfolio]..CovidDeaths$ dea
JOIN [Project Portfolio]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3




