select *
from PortfolioProject..CovidDeaths
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths at certain country 
-- shows liklyhood of dying if you contract covid in your country 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%taiwan%'
order by 1,2

-- looking at total cases vs population 
-- shows what percentage of population got Covid 

select location, date,population, total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at the country with highest infection rate compared to population  

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageInfected
from PortfolioProject..CovidDeaths
--don't forget to group by when using aggregation function 
group by location, population
order by PercentageInfected desc 

-- showing countires with highest death count per population 
-- change the total_deaths data type from varchar to int, happend a lot 

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- go back to change when select data set continent is not null 
where continent is not null 
group by location
order by TotalDeathCount desc 

-- Let's break up by continent 

--What is wrong here? 
--select continent, max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
--where continent is not null 
--group by continent
--order by TotalDeathCount desc 

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- go back to change when select data set continent is not null 
where continent is null 
group by location
order by TotalDeathCount desc 


-- still using this so won'r break tabluet drill down view  
-- showing Global Numbers 

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int)) / sum(new_cases) *100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null 
--group by date
order by 1,2    


-- looking at total polulation vs vaccinations per day 

Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPplVaccinated
--, RollingPplVaccinated/population)*100 
from PortfolioProject..CovidDeaths as dea 
join PortfolioProject..CovidVaccinations as vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3 


-- USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPplVaccinated)
as
(
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPplVaccinated 
from PortfolioProject..CovidDeaths as dea 
join PortfolioProject..CovidVaccinations as vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (RollingPplVaccinated/population)*100 as VaccinatedPercentage 
from PopvsVac


-- USE TEMP TABLE 

drop table if exists  #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated 
(
Continent nvarchar (255),
Location nvarchar(255),
Data datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths as dea 
join PortfolioProject..CovidVaccinations as vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage 
from #PercentPopulationVaccinated 


-- Creating View to store data for later visualizations 

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths as dea 
join PortfolioProject..CovidVaccinations as vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3  you can't use order by in view  


select * 
from PercentPopulationVaccinated 

