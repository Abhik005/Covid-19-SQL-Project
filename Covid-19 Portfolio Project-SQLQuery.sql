Select * from CovidDeaths
order by 3,4

Select * from CovidVaccinations
order by 3,4

Select location,date, total_cases,new_cases,total_deaths,population from CovidDeaths
order by 1,2

Select location,date, total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
order by 1,2


Select location,date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%states%'
order by 1,2

Select location,population, max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
group by location,population
order by PercentPopulationInfected desc


Select location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

Select location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

Select date , SUM(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null 
Group by date
order by 1,2

Select SUM(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null 
--Group by date
order by 1,2

--Joining both Tables

Select * from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date , population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


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
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * from 
PercentPopulationVaccinated

