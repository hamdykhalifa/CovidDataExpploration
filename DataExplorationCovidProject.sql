
Select *
From PortfolioProjectAlexFreberg..CovDeaths$
Where continent is not null
order by 3,4

-- Select useful data for later 

Select location, date, CONVERT(Decimal(15,1), total_cases) as TotalCases, CONVERT(decimal(15,1), new_cases) as NewCases, CONVERT(decimal(15,1), total_deaths) as TotalDeaths, CONVERT(decimal(15, 1), population) as Population
FROM PortfolioProjectAlexFreberg..CovDeaths$
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (Convert(decimal(15,1),total_deaths)/total_cases) * 100 as Deathrate
FROM PortfolioProjectAlexFreberg..CovDeaths$
Where location like '%Germany%'
order by 1,2

-- Total Cases vs Population (Infectionrate)

Select location, date, total_cases, population, (total_cases/Convert(Decimal(15,1),population)) * 100 as Infectionrate
FROM PortfolioProjectAlexFreberg..CovDeaths$
Where location like '%Germany%'
order by 1,2


-- Countries with highest infectionrate compared to population
Select location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Convert(Decimal(15,1),population))) * 100 as MaxInfectionrate
FROM PortfolioProjectAlexFreberg..CovDeaths$
Where continent is not null
Group by location, population
order by MaxInfectionrate desc

-- highest death count per population

Select location,population, MAX(CONVERT(Decimal(15,1), total_deaths)) as HighestDeathCount, Max(CONVERT(Decimal(15,1), total_deaths)/CONVERT(Decimal(15,1), population)) * 100 as MaxDeathrate
FROM PortfolioProjectAlexFreberg..CovDeaths$
Where continent is not null
Group by location, population
order by MaxDeathrate desc

-- Ordering by continents
Select location, MAX(CONVERT(Decimal(15,1), total_deaths)) as TotalDeathCount
FROM PortfolioProjectAlexFreberg..CovDeaths$
Where continent is  null
Group by location
order by TotalDeathCount desc


-- GLobal Numbers
Select date, SUM(CONVERT(decimal(15,1), new_cases)) as totalCases, Sum(Convert(decimal(15,1), new_deaths)) as totalDeaths, (Sum(Convert(decimal(15,1),new_deaths))/Sum(Convert(decimal(15,1),new_cases))) * 100  as GlobalDeathRate
FROM PortfolioProjectAlexFreberg..CovDeaths$
Where  continent is  not null
Group by date
order by 1,2


-- Looking at total population vs vaccination with CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, StackedVaccineCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(decimal(15,1), vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as StackedVaccineCount
From PortfolioProjectAlexFreberg..CovDeaths$ dea
Join PortfolioProjectAlexFreberg..CovVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (StackedVaccineCount/Convert(decimal, Population))*100 as VacPercentage
From PopvsVac

-- Temp Table

Drop Table if exists #DeathCount
Create Table #DeathCount
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Deaths numeric,
StackedDeathCount numeric
)

Insert into #DeathCount
Select dea.continent, dea.location, dea.date, dea.population, dea.new_deaths
, SUM(Convert(decimal(15,1), dea.new_deaths)) Over (Partition by dea.location Order by dea.location, dea.date) as StackedDeathCount
From PortfolioProjectAlexFreberg..CovDeaths$ dea
Join PortfolioProjectAlexFreberg..CovVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (StackedDeathCount/Convert(decimal, Population))*100 as DeathPercentage
From #DeathCount


-- Creating view to store data for viz

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(decimal(15,1), vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as StackedVaccineCount
From PortfolioProjectAlexFreberg..CovDeaths$ dea
Join PortfolioProjectAlexFreberg..CovVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated