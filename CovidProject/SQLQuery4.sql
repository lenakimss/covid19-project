select *
from CovidProject
order by 3,4 

--select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total Cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths
--where location like '%state%'
where continent is not null
order by 1,2

--Looking at the Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from CovidProject..CovidDeaths
--where location like '%state%'
where continent is not null
order by 1,2

--Looking at country with highest infection rate compared to population

Select Location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentagePopulationInfected
from CovidProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by location, population
order by PercentagePopulationInfected desc



--Let's break things down by continents

--Showing the continent with highest death count per population

Select continent, max(cast(total_deaths as int)) as TotaDeathCount
from CovidProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by TotaDeathCount desc



--Global numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths
where continent is not null
order by 1,2 


--Looking at total population vs vaccinations
--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
 as 
 (
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated