SELECT *
FROM Portofolio_project..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM Portofolio_project..CovidVaccinations
--order by 3,4
-- Select Data that we are going to be using

SELECT Location, date, total_cases,total_deaths, population
from Portofolio_project..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from Portofolio_project..CovidDeaths
where Location = 'Indonesia'
order by 1,2

-- Looking at the Total Cases vs the Population
-- shows what percentage of population got covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS CasePercentage
from Portofolio_project..CovidDeaths
--where Location = 'Indonesia'
order by 1,2

-- Looking at Country with highest infection rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfect
from Portofolio_project..CovidDeaths
--where Location = 'Indonesia'
Group By Location,Population
order by PercentPopulationInfect desc


-- Let's break things down by continent
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portofolio_project..CovidDeaths
where continent is not null
--where Location = 'Indonesia'
Group By continent
order by TotalDeathCount desc


-- Showing countries with Highest Deatch Count per Population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portofolio_project..CovidDeaths
where continent is not null
--where Location = 'Indonesia'
Group By Location
order by TotalDeathCount desc

-- showing the continent with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portofolio_project..CovidDeaths
where continent is not null
--where Location = 'Indonesia'
Group By continent
order by TotalDeathCount desc


-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
from Portofolio_project..CovidDeaths
--where Location = 'Indonesia'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopVaccinated
FROM Portofolio_project..CovidDeaths dea
JOIN Portofolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopVaccinated
FROM Portofolio_project..CovidDeaths dea
JOIN Portofolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopVaccinated/Population)*100
from PopvsVac



-- TEMP Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopVaccinated  numeric
)

insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopVaccinated
FROM Portofolio_project..CovidDeaths dea
JOIN Portofolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

select *, (RollingPeopVaccinated/Population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopVaccinated
FROM Portofolio_project..CovidDeaths dea
JOIN Portofolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated