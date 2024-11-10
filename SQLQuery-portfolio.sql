select *
from beheo..CovidDeaths
order by 3,4

--select *
--from beheo..CovidVaccination
--order by 3,4

---select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from beheo..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
--- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from beheo..CovidDeaths
where location like '%states%'
order by 1,2

--- Looking at Total Cases vs Population
--- shows what percentage of population got covid
select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from beheo..CovidDeaths
where location like '%states%'
order by 1,2

--- Looking at countries with Highest Infection Rate compared to Population
SELECT 
    location, 
    population, 
    MAX(total_cases) AS HighestInfectionCount, 
    (MAX(total_cases) / population) * 100 AS PercentPopulationInfected
FROM 
    beheo..CovidDeaths
--WHERE location LIKE '%states%' -- Uncomment this if you want to filter by location containing "states"
GROUP BY 
    location, population
ORDER BY 
    PercentPopulationInfected desc;


	--- showing the country with the hightest death count per population 
SELECT 
    location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM 
    beheo..CovidDeaths
--WHERE location LIKE '%states%' -- Uncomment this if you want to filter by location containing "states"
where continent is null
GROUP BY 
    location
ORDER BY 
    TotalDeathCount desc;

--- Lets break things down by continent
SELECT 
    continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM 
    beheo..CovidDeaths
--WHERE location LIKE '%states%' -- Uncomment this if you want to filter by location containing "states"
where continent is not null
GROUP BY 
    continent
ORDER BY 
    TotalDeathCount desc;

-- GLOBAL NUMBER 
select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent --population, total_cases,(total_deaths/total_cases)*100 as DeathPercentage
from beheo..CovidDeaths
--where location like '%states%'
where continent is not null
---GROUP BY date 
order by 1,2

--- Loooking at total vaccinations
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVacinated)
as
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVacinated
---,(RollingPeopleVacinated/population)*100
from beheo..CovidDeaths dea
Join beheo..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVacinated/Population)*100
from PopvsVac

-- temp table

-- Drop the temporary table if it exists
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
BEGIN
    DROP TABLE #PercentPopulationVaccinated;
END;

-- Create the temporary table
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Insert data into the temporary table
INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM beheo..CovidDeaths dea
JOIN beheo..CovidVaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Select data from the temporary table with calculated percentage
SELECT 
    *,
    (RollingPeopleVaccinated * 100.0 / NULLIF(Population, 0)) AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;


--- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVacinated
---,(RollingPeopleVacinated/population)*100
from beheo..CovidDeaths dea
Join beheo..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---order by 2,3

Select *
from PercentPopulationVaccinated