select *
from PortfolioProject..CovidVaccines
--where continent is not null
order by 3,4

--Selecting data we're going to use
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Likelihood of dying if you have covid19
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%United States%'
order by 1,2

-- Total Cases vs Population
-- Shows percentage of population who got covid
select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where location like '%United States%'
order by 1,2


-- Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by InfectedPercentage desc

-- Countries with how many people have died from covid
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount desc

--Showing contientents with the highest deathcount
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is  null
group by location
order by TotalDeathCount desc

--Global pandemic
select date, sum(new_cases) as GlobalNewCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Global pandemic totals only (1 row)
select sum(new_cases) as GlobalNewCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--Joining Deaths w/ Vaccines
select * 
from PortfolioProject..CovidDeaths deaths
join 
PortfolioProject..CovidVaccines vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date


--  Total population vs vaccinations
select deaths.continent, deaths.location, deaths.date, vacs.new_vaccinations as NewVaccPerDay
from PortfolioProject..CovidDeaths deaths
join PortfolioProject..CovidVaccines vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
order by 2,3


-- World Wide: Total Vaccinations Each Day
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, Sum(convert(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as EachDayTotalVaccinated
from PortfolioProject..CovidDeaths deaths
join PortfolioProject..CovidVaccines vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
order by 2,3

-- USE CTE (Common Table Expression) 
With PopVsVacc (continent, location, date, population, new_vaccinations,  EachDayTotalVaccinated)
as 
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, Sum(convert(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as EachDayTotalVaccinated
from PortfolioProject..CovidDeaths deaths
join PortfolioProject..CovidVaccines vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
)

select *, (EachDayTotalVaccinated/population)*100 as DailyVaccinatedPercentage
from PopVsVacc


--Creating TEMP Table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
EachDayTotalVaccinated numeric
)
Insert into #PercentPopulationVaccinated

select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, Sum(convert(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as EachDayTotalVaccinated
from PortfolioProject..CovidDeaths deaths
join PortfolioProject..CovidVaccines vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null

select *, (EachDayTotalVaccinated/population)*100 as DailyVaccinatedPercentage
from #PercentPopulationVaccinated




--Creating View to store data later for visualizations
Create View PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, Sum(convert(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as EachDayTotalVaccinated
from PortfolioProject..CovidDeaths deaths
join PortfolioProject..CovidVaccines vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
























































