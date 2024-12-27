select * from PortfolioProjectdb..CovidDeaths$
order by 3,4

select * from PortfolioProjectdb..CovidDeaths$
where continent is not null
order by 3,4

-- select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjectdb..CovidDeaths$
where continent is not null
order by 1,2


-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjectdb..CovidDeaths$
where location like '%state%'
and continent is not null
order by 1,2

--looking at total cases vs population
--show what percentage of population got covid

select location, date, population,  total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjectdb..CovidDeaths$
where continent is not null
--where location like '%state%'
order by 1,2

-- looking at countries with highest infection rate compared to population

 select location, population,  MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjectdb..CovidDeaths$
--where location like '%state%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectdb..CovidDeaths$
--where location like '%state%'
where continent is not null
group by location
order by TotalDeathCount desc

--lets break thing down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectdb..CovidDeaths$
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc

--lets break things down by locations

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectdb..CovidDeaths$
--where location like '%state%'
where continent is null
group by location
order by TotalDeathCount desc

-- global numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjectdb..CovidDeaths$
--where location like '%state%'
where continent is not null
group by date
order by 1,2

SELECT date, 
       SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as int)) as total_deaths, 
       (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DeathPercentage
FROM PortfolioProjectdb..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) > 0 -- Filter aggregated results here
ORDER BY date, total_cases;




select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjectdb..CovidDeaths$
--where location like '%state%'
where continent is not null
--group by date
order by 1,2


--or we can write like this


SELECT SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as int)) as total_deaths, 
       CASE 
           WHEN SUM(new_cases) = 0 THEN 0
           ELSE SUM(cast(new_deaths as int))/SUM(new_cases)*100
       END as DeathPercentage
FROM PortfolioProjectdb..CovidDeaths$
WHERE continent IS NOT NULL;


--or

SELECT SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as int)) as total_deaths, 
       SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjectdb..CovidDeaths$
WHERE continent IS NOT NULL;



select *
from PortfolioProjectdb..CovidDeaths$ dea
JOIN PortfolioProjectdb..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total popultion vs vaccination

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectdb..CovidDeaths$ dea
JOIN PortfolioProjectdb..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (contitnent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectdb..CovidDeaths$ dea
JOIN PortfolioProjectdb..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100

--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectdb..CovidDeaths$ dea
JOIN PortfolioProjectdb..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

drop table if exists #PercentPopulationVaccinated;

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectdb..CovidDeaths$ dea
JOIN PortfolioProjectdb..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

use PortfolioProjectdb;
SELECT DB_NAME() AS CurrentDatabase;

select *
from PercentPopulationVaccinated




select location, sum(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProjectdb..CovidDeaths$
where continent is not null
and location not in ('world', 'european union', 'international')
group by location
order by TotalDeathCount desc


select location, population, max(total_cases) as HighInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjectdb..CovidDeaths$
group by location, population
order by PercentPopulationInfected desc





















