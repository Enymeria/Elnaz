select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

select location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths in Canada

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location='Canada'
order by 1,2

-- Total Cases vs Population

select location,date, total_cases, population, (total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
where location='Canada'
order by 1,2

--Countries with the highest infection rates

select location, population, max(total_cases) as HighestInfectionRate, max(total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
Group by location, population
order by InfectionRate desc

--Countries with the highest deathcount per population

select location, population, max(cast (total_deaths as int)) as TotalDeathCount, max(total_deaths/population)*100 as DeathRate
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by DeathRate desc

--Countries with the highest deathcount

select location, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Continents with the highest deathcount

select continent, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global info

select date, sum(cast(new_deaths as int)) as TotalDeaths, sum(new_cases) as TotalCases, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by date 

select  sum(cast(new_deaths as int)) as TotalDeaths, sum(new_cases) as TotalCases, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by Deathpercentage desc;

--Total Population vs Vacvination

--CTE

with PopvsVac (continent, Location, date, Population, new_vaccines, AggregatedVac)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as AggregatedVac

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select * , (AggregatedVac/Population)*100 as VacRate
from PopvsVac
order by Location,date

--Temp table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(225) ,
Location nvarchar(225),
date datetime,
Population numeric,
new_vaccines numeric,
AggregatedVac numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as AggregatedVac

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select * , AggregatedVac/Population *100 as VacRate
from #PercentPopulationVaccinated
where location= 'canada'
order by Location, DATE


--Create View

Create view PercentPopulationVaccinated 
as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as AggregatedVac

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select*
from PercentPopulationVaccinated

