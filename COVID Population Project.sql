select*
from PortfolioProject..CovidDeaths$
where continent is not null

order by 3,4


--select*
--from PortfolioProject..CovidVaccinations$
--order by 3,4


order by 1,2
--lokking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (convert(decimal(18,2),total_deaths)/convert(decimal(18,2),total_cases))
from PortfolioProject..CovidDeaths$
order by 1,2

select Location, date, total_cases, total_deaths, cast(total_deaths as bigint)/cast(total_cases as bigint)*.01
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
select Location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths$
where location like 'United States'
where continent is not null
order by 1,2

--Lokking at country with highest infection rate compared to population
select Location, population, MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths$
--where location like 'United States'
group by Location, population
order by PercentPopulationInfected desc
 
--let's break things by continent 
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by totalDeathCount desc




--Showing continent with heghest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
--where location like 'United States'
where continent is not null
group by continent
order by TotalDeathCount desc



--Use CTE

with PopvsVac(continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
--looking at total population vs total vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT* ,(RollingPeopleVaccinated/population)*100
from PopvsVac



--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT* ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating view to store data for visualization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from PercentPopulationVaccinated

 







