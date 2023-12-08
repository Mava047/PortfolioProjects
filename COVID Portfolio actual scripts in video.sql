Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4


--Selecting data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2


--Looking at Total Cases vs Total Deaths
--Shows the likelyhood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2


--looking at the total cases vs population
--shows what percsntage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1, 2


-- Lookiong at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, Population
order by PercentageOfPopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
Group by Location
order by TotalDeathCount desc


--Lets break things down by continent

Select Continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
Group by Continent
order by TotalDeathCount desc


--Showing the continents with the highest death count per population

Select Continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
Group by Continent
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
Order by 2, 3



--Using CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Using Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2, 3

Select *
from PercentPopulationVaccinated