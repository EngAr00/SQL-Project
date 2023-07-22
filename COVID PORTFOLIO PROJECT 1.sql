select *
From [PORTFOLIO PROJECT].dbo.CovidDeaths
order by 3,4

select *
from [PORTFOLIO PROJECT].dbo.CovidVaccinations
order by 3,4

--select data we're going to be using

select location,date,total_cases,new_cases,total_deaths,population
From [PORTFOLIO PROJECT].dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PORTFOLIO PROJECT].dbo.CovidDeaths
where location like '%Kenya%'
order by 1,2


--Looking total cases vs population
select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationAffected
From [PORTFOLIO PROJECT].dbo.CovidDeaths
where location like '%Kenya%'
order by 1,2

--Looking at countries highest infection rate compared population

select location,population,MAX(total_cases) as HighestInfectionCount,MAX( (total_cases/population)*100 )as HighestPercentAffected
From [PORTFOLIO PROJECT].dbo.CovidDeaths
--where location like '%Kenya%'
group by location,population
order by HighestPercentAffected desc

--Looking with countries with highest percentage death count per population

select location,population,MAX(total_deaths) as HighestDeathCount,MAX((total_deaths/population))*100 as HighestPercentDeathCount
From [PORTFOLIO PROJECT].dbo.CovidDeaths
where continent is not null
group by location,population
order by HighestPercentDeathCount

--Looking countries with highest death rate
select location,MAX(cast (total_deaths as int)) as HighestDeathCount
From [PORTFOLIO PROJECT].dbo.CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc


--Looking continent with highest death rate
select location,MAX(cast (total_deaths as int)) as HighestDeathCount
From [PORTFOLIO PROJECT].dbo.CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc



--GLOBAL NUMBERS
select date,SUM(cast(new_cases as int)) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageDeathPerday
from [PORTFOLIO PROJECT].dbo.CovidDeaths
where continent is not null 

group by date
order by 1,2

--Joins
--Total Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
from [PORTFOLIO PROJECT].dbo.CovidDeaths dea
join [PORTFOLIO PROJECT].dbo.CovidVaccinations vac
    ON dea.location=vac.location and
	   dea.date=vac.date
where dea.continent is not null
order by 1, 2,3

--USE CTEs
WITH PopVsVac as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
from [PORTFOLIO PROJECT].dbo.CovidDeaths dea
join [PORTFOLIO PROJECT].dbo.CovidVaccinations vac
    ON dea.location=vac.location and
	   dea.date=vac.date
where dea.continent is not null
--order by 1, 2
)
select *, (RollingPopulationVaccinated/population)*100 as PercentRollingPple
from PopVsVac


---TEMP TABLES
DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPopulationVaccinated numeric
 ) 
 insert into #PercentPopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
from [PORTFOLIO PROJECT].dbo.CovidDeaths dea
join [PORTFOLIO PROJECT].dbo.CovidVaccinations vac
    ON dea.location=vac.location and
	   dea.date=vac.date
where dea.continent is not null
--order by 1, 2

select *, (RollingPopulationVaccinated/population)*100 as PercentRollingPopulation
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PORTFOLIO PROJECT].dbo.CovidDeaths dea
Join [PORTFOLIO PROJECT].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
select *
from PercentPopulationVaccinated


