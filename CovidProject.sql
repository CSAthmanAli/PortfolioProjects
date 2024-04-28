SELECT TOP 10 * FROM dbo.CovidDeaths
ORDER BY 3,4  --column 3 and 4 i.e.loc and date

SELECT * FROM dbo.CovidVaccinations
ORDER BY 3,4  

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM dbo.CovidDeaths
ORDER BY 1,2

--total cases vs total deaths; shows likelihood of dying in ur country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as "% of deaths"
FROM dbo.CovidDeaths
WHERE location='Kenya'
ORDER BY 1,2

--total cases vs population
SELECT location,date,population,total_cases,(total_cases/population)*100 as "% of population with Covid"
FROM dbo.CovidDeaths
WHERE location='Kenya'
ORDER BY 1,2

--Countries with higest infection rate compared to population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--new cases vs new deaths
Select date, SUM(new_cases) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercent
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by date
order by NewDeathPercent desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--new vaccinations & cummulative vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CummulativeNewVaccinations
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, CummulativeNewVaccinations)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CummulativeNewVaccinations
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(CummulativeNewVaccinations/population)*100 as PercentCummulativeNewVaccinationsByPopulation FROM PopvsVac


--drop table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population nvarchar(255),
	new_vaccinations numeric,
	CummulativeNewVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CummulativeNewVaccinations
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *,(CummulativeNewVaccinations/population)*100 as PercentCummulativeNewVaccinationsByPopulation 
FROM #PercentPopulationVaccinated


DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
