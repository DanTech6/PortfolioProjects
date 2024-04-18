--select *
--from PortfolioProjects ..CovidVaccinations$

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProjects ..CovidDeaths$
order by 1,2 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects ..CovidDeaths$
where location like '%Africa%'
order by 1,2 


select location,date,total_cases,population,(total_cases/population)*100 as InfectedPercentage
from PortfolioProjects ..CovidDeaths$
where location = 'Africa'
order by 1,2


select location,population,max(total_cases) as HighestInfectionRate,max(total_cases/population)*100 as InfectedPercentage
from PortfolioProjects ..CovidDeaths$
--where location = 'Africa'
group by population, location
order by InfectedPercentage desc

select continent,max(CAST( total_deaths as int)) as TotalDeathCount
from PortfolioProjects ..CovidDeaths$
--where location = 'Africa'
where continent is not null
group by continent
order by TotalDeathCount desc

select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjects ..CovidDeaths$
where continent is not null
group by date
order by 1,2 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProjects ..CovidDeaths$ dea
join PortfolioProjects ..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
	over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from PortfolioProjects ..CovidDeaths$ dea
join PortfolioProjects ..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopsVac(continent,location,date,population,new_vaccinations,Rolling_People_Vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
	over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from PortfolioProjects ..CovidDeaths$ dea
join PortfolioProjects ..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rolling_People_Vaccinated/population)*100 as VaccinatedPercentage
from PopsVac

--create views
create view PopsVac
as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
	over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from PortfolioProjects ..CovidDeaths$ dea
join PortfolioProjects ..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PopsVac