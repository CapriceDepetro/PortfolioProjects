select * from [Portfolio Project]..CovidDeaths$
order by 3,4

select * from [Portfolio Project]..CovidVaccinations$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths$
order by 1,2

--people fully vaccinated by continent

select location, date, people_fully_vaccinated
from [Portfolio Project]..CovidVaccinations$
where continent is null
order by 1,2

--Looking at total cases vs total deaths in US: shows likliness of death if infected with covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as PercentageOfDeath
from [Portfolio Project]..CovidDeaths$
where location like 'united states'
order by 1,2

--total cases vs population of US

select location, date, total_cases, population, (total_cases/population)* 100 as PercentageOfInfection
from [Portfolio Project]..CovidDeaths$
where location like 'united states'
order by 1,2 

--highest rates of infection vs population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))* 100 as MaxPercentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by location, population
order by MaxPercentage desc

-- highest death rates vs population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--total deaths by continent

select location, max(cast(total_deaths as int)) as TotalDeaths
from [Portfolio Project]..CovidDeaths$
where continent is null
group by location
order by TotalDeaths desc

--worldwide numbers of cases and deaths

select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as GlobalDeathRate
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by date
order by 1,2

--total number of cases and deaths as of 4/20/21

select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as GlobalDeathRate
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2


--joining CovidDeaths table and CovidVaccinations table

select * from [Portfolio Project]..CovidDeaths$ deaths
join [Portfolio Project]..CovidVaccinations$ vax
on deaths.location = vax.location 
and deaths.date =vax.date 

--total population vs vaccinations

select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
sum(cast(vax.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as RollingVaccinations
from [Portfolio Project]..CovidDeaths$ deaths
join [Portfolio Project]..CovidVaccinations$ vax
	on deaths.location = vax.location 
	and deaths.date =vax.date
where deaths.continent is not null
order by 1, 2, 3

-- creating a cte to perform a calculation on partition by in previous query

with PopVsVax (Continent, location, date, population, new_vaccinations, RollingVaccinations)
as 
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
sum(cast(vax.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as RollingVaccinations
from [Portfolio Project]..CovidDeaths$ deaths
join [Portfolio Project]..CovidVaccinations$ vax
	on deaths.location = vax.location 
	and deaths.date =vax.date
where deaths.continent is not null
)
select *, (RollingVaccinations/population) * 100 from PopVsVax

--temp table to perform calculation on partition by in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)

insert into #PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
sum(cast(vax.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as RollingVaccinations
from [Portfolio Project]..CovidDeaths$ deaths
join [Portfolio Project]..CovidVaccinations$ vax
	on deaths.location = vax.location 
	and deaths.date =vax.date


select *, (RollingVaccinations/population) * 100 
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
sum(cast(vax.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as RollingVaccinations
from [Portfolio Project]..CovidDeaths$ deaths
join [Portfolio Project]..CovidVaccinations$ vax
	on deaths.location = vax.location 
	and deaths.date =vax.date 
where deaths.continent is not null


create view TotalDeathsByCountry as
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by location


create view TotalDeathsbyContinent as
select location, max(cast(total_deaths as int)) as TotalDeaths
from [Portfolio Project]..CovidDeaths$
where continent is null
group by location

create view GlobalDeathRateByDate as
select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as GlobalDeathRate
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by date

create view FullyVaxedPeopleByContinent as
select location, date, people_fully_vaccinated
from [Portfolio Project]..CovidVaccinations$
where continent is null

create view DeathPercentage as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
where continent is not null 
Group By date

