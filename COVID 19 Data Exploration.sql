select *
from [Portfolio Project]..CovidDeaths
order by  3,4

--select *
--from [Portfolio Project]..CovidVaccinations
--order by  3,4

-- Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Probability of dying if you contract COVID in your country (ex: Spain)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate 
from [Portfolio Project]..CovidDeaths
where location = 'Spain'
order by 1,2

-- Looking at Total Cases vs Population 
-- Population got COVID

Select Location, date, population, total_cases, (total_cases/population)*100 as cases_per_population  
from [Portfolio Project]..CovidDeaths
where location = 'Spain'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population 

Select date, Location, population, Max(total_cases) as highest_infection_rate_per_country,Max((total_cases/population))*100 as max_cases_per_population 
from [Portfolio Project]..CovidDeaths
--where location = 'Spain'
group by date,location,population
order by max_cases_per_population desc

-- Showing countries with Highest Death Count per Population #1

Select Location, population, Max(cast(total_deaths as int)) as highest_death_rate_per_country, Max((total_deaths/population))*100 as max_death_per_population 
from [Portfolio Project]..CovidDeaths
--where location = 'Spain'
where continent is not null 
group by location, population
order by max_death_per_population desc

-- Showing countries with Highest Death Count per Population #2

Select Location, Max(cast(total_deaths as int)) as highest_death_rate_per_country
from [Portfolio Project]..CovidDeaths
--where location = 'Spain'
where continent is not null 
group by location
order by highest_death_rate_per_country desc

-- Let's break things down by CONTINENT: 

-- Continent Not null (version) will give not accurate rates (ex: North America not add Canada deaths)

Select continent, Max(cast(total_deaths as int)) as highest_death_rate_per_continent
from [Portfolio Project]..CovidDeaths
--where location = 'Spain'
where continent is not null 
group by continent
order by highest_death_rate_per_continent desc

-- To have accurate rates we FIX IT 

Select location, Max(cast(total_deaths as int)) as highest_death_rate_per_country
from [Portfolio Project]..CovidDeaths
--where location = 'Spain'
where continent is null 
group by location
order by highest_death_rate_per_country desc


-- Continent Null 

Select continent, Max(cast(total_deaths as int)) as highest_death_rate_per_continent
from [Portfolio Project]..CovidDeaths
--where location = 'Spain'
where continent is null 
group by continent
order by highest_death_rate_per_continent desc


-- Showing continents with highest death count per population 

Select continent, Max(cast(total_deaths as int)) as highest_death_rate_per_continent
from [Portfolio Project]..CovidDeaths
--where location = 'Spain'
where continent is not null 
group by continent
order by highest_death_rate_per_continent desc





-- GLOBAL NUMBERS 

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_rate_global 
from [Portfolio Project]..CovidDeaths
--where location = 'Spain'
where continent is not null 
--Group by date 
order by 1,2


-- Looking at Total Population vs Vaccinations

WITH UniqueVaccinations AS (SELECT location, date, MAX(CAST(new_vaccinations AS INT)) AS new_vaccinations
FROM [Portfolio Project]..CovidVaccinations
GROUP BY location, date)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations_running
FROM [Portfolio Project]..CovidDeaths dea
JOIN UniqueVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date


-- Use CTE 

WITH UniqueVaccinations AS (SELECT location, date, MAX(CAST(new_vaccinations AS INT)) AS new_vaccinations
     FROM [Portfolio Project]..CovidVaccinations GROUP BY location, date)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations_running,
    (CAST(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS FLOAT)
     / dea.population) * 100 AS percent_population_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN UniqueVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date





-- TEMP TABLE to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated 
( Continent NVARCHAR(255), Location NVARCHAR(255), Date DATETIME, Population NUMERIC, New_vaccinations NUMERIC, 
    total_vaccinations_running NUMERIC, percent_population_vaccinated FLOAT);

WITH UniqueVaccinations AS (SELECT location, date, MAX(CAST(new_vaccinations AS INT)) AS new_vaccinations
     FROM [Portfolio Project]..CovidVaccinations GROUP BY location, date)

INSERT INTO #PercentPopulationVaccinated(Continent, Location, Date, Population, New_vaccinations, total_vaccinations_running, percent_population_vaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations_running,(CAST(SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.date) AS FLOAT) / dea.population) * 100 AS percent_population_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN UniqueVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

SELECT *
FROM #PercentPopulationVaccinated;




-- Creating View to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated AS
WITH UniqueVaccinations AS (SELECT location, date, MAX(CAST(new_vaccinations AS INT)) AS new_vaccinations
    FROM [Portfolio Project]..CovidVaccinations
    GROUP BY location, date)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations_running, (CAST(SUM(vac.new_vaccinations) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS FLOAT) / dea.population) * 100  AS percent_population_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN UniqueVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;