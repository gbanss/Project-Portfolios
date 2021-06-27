Select * 
From PortfolioProject..CovidDeaths 
order by 3, 4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3, 4


--Select Data that we are going to be using 
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got COVID

Select Location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
group by population, location
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where continent is not null --eliminates null continent counts to show just country counts
group by location	
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT	

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
where continent is not null --eliminates Null continent counts from queries
group by continent	
order by TotalDeathCount desc





-- Global Numbers measuring Daily Total Cases and Deaths, and Death Percentage

Select date, SUM(new_cases) as Total_Cases, SUM(cast (new_deaths as int)) as Total_Deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
WHERE continent is not null
group by date
order by 1,2


Select  SUM(new_cases) as Total_Cases, SUM(cast (new_deaths as int)) as Total_Deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
WHERE continent is not null
--group by date
order by 1,2



-- Looking @ Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as VaccinatedToDate
--(VaccinatedToDate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null	
order by 2,3

--USE CTE 
-- if number of columns of CTE is different from the first table, then you'll get error

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinatedToDate)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as VaccinatedToDate
--(VaccinatedToDate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null	
--order by 2,3
)
Select *, (VaccinatedToDate/Population)*100 as PercentageVaccinatedToDate 
From PopvsVac




--- TEMP TABLE
Drop table if exists #PercentagePopulationVaccinated -- if temp table already in database
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinatedToDate numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as VaccinatedToDate
--(VaccinatedToDate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null	
--order by 2,3
Select *, (VaccinatedToDate/Population)*100 as PercentageVaccinatedToDate 
From #PercentPopulationVaccinated




-- Creating view to store data from later visualizations


Create view PopvsVac as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as VaccinatedToDate
--(VaccinatedToDate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null	
--order by 2,3

Select * 
From PopvsVac