/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as percentage
from covid_death
where location like 'Canada'
order by 6 desc;

-- Countries with Highest Infection Rate compared to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_death
Where location like 'Canada'
Group by Location, Population
order by location;

-- Countries with Highest Death Count per Population
Select location, MAX(total_deaths)/population*100 as TotalDeathPercent
From covid_death
Where continent is not null 
Group by Location, population
having MAX(total_deaths)>0
order by TotalDeathPercent desc;

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From covid_death
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS by date

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
(SUM(new_deaths)/SUM(new_cases)*100) as DeathPercentage 
From covid_death
where continent is not null 
Group By date 
order by 1;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
(SUM(new_deaths)/SUM(new_cases)*100) as DeathPercentage 
From covid_death
where continent is not null;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over 
(partition by dea.location order by dea.date rows unbounded preceding)
as Vaccin_Running_Total
from covid_death as dea
join covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date;



-- Using Temp Table to perform Calculation on Partition By in previous query

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
From covid_death dea
Join covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
	as RollingPeopleVaccinated
From covid_death dea
Join covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.location = 'Canada'
)
Select *, (RollingPeopleVaccinated/Population)*100 as Rolling_Vac_Percent
From PopvsVac;


-- Creating View to store data for later visualizations

Create or Replace View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid_death dea
Join covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
































