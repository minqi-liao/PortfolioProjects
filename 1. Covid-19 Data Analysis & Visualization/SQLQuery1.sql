select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

select location,date,total_cases,new_cases,total_deaths from PortfolioProject..CovidDeaths
order by 1,2

--look at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Look at Total Cases vs Population
--shows what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as PositivePercentage
from PortfolioProject..CovidDeaths
where location like '%china%'
order by 1,2

--look at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestinfectioncount,max((total_cases/population)*100) as Percentagepopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%china%'
group by location,population
order by 4 desc

--show countries with highest death count per population
select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by 2 desc

--let's break things down by continent
select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by 2 desc

--showing continents with the highest death count per population
select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is null
group by continent
order by 2 desc

--global numbers
select sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathspercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--use CTE
with popvsvac (Continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac

--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--create view to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

--
select * from percentpopulationvaccinated
