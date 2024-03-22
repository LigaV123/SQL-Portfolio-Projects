/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * 
From CovidDeaths
Where continent Is Not Null
Order by 3, 4



-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, new_deaths, population
From CovidDataPractice..CovidDeaths
Where continent Is Not Null
Order by 1, 2



-- total_cases VS total_deaths
-- Shows likelihood of dying when getting sick with covid in Latvia

Select location, date, total_cases, total_deaths 
	, (Cast(total_deaths As float)/Cast(total_cases As float))*100 As DeathPercentage
From CovidDataPractice..CovidDeaths
Where location = 'Latvia'
--Where continent Is Not Null --for global view
And total_cases Is Not Null  --for easier visibility
Order by 1, 2



-- total_cases VS population
-- Shows what percentage of population got Covid in Latvia

Select location, date, population, total_cases
	, (Cast(total_cases As float)/population)*100 As PercentPopulationInfected
From CovidDataPractice..CovidDeaths
Where location Like '%latvia%'
--Where continent Is Not Null --for global view
And total_cases Is Not Null
Order by 1, 2



-- Countries with highest infection rate compared to population

Select location, population 
	, Max(Cast(total_cases As int)) As HighestInfectionCount
	, (Max(Cast(total_cases As float))/population)*100 As PercentPopulationInfected
From CovidDataPractice..CovidDeaths
Where continent Is Not Null
Group By location, population
Order by PercentPopulationInfected Desc



-- Countries with highest death count compared to population

Select location, population 
	, Max(Cast(total_deaths As int)) As HighestDeathCount
	, (Max(Cast(total_deaths As float))/population)*100 As PopulationDeathPercentage
From CovidDataPractice..CovidDeaths
Where continent Is Not Null
Group By location, population
Order by PopulationDeathPercentage Desc



-- Countries with highest death count

Select location 
	, Max(Convert(int, total_deaths)) As TotalDeathCount
From CovidDataPractice..CovidDeaths
Where continent Is Not Null
Group By location
Order by TotalDeathCount Desc



-- BREAKING THINGS DOWN BY CONTINENT
-- 6 main continents (North America, South America, Asia, Europe, Africa, Oceania)

Select continent 
	, Max(Cast(total_deaths As int)) As TotalDeathCount
From CovidDataPractice..CovidDeaths
Where continent Is Not Null
Group By continent
Order by TotalDeathCount Desc



-- 6 main continents with - World, European Union, High income, Upper middle income, Lower middle income, Low income

Select location 
	, Max(Cast(total_deaths As int)) As TotalDeathCount
From CovidDataPractice..CovidDeaths
Where continent Is Null
Group By location
Order by TotalDeathCount Desc



-- GLOBAL NUMBERS

-- total_deaths VS total_cases by date

Select date,
	Sum(Cast(total_cases As int)) As TotalCases
	, Sum(Convert(int, total_deaths)) As TotalDeaths
	, Sum(Convert(float, total_deaths))/Sum(Cast(total_cases As float))*100 As DeathPercentage
From CovidDataPractice..CovidDeaths
Where continent Is Not Null 
Group by date
Order by 1



-- total_cases, total_deaths and death percentage globaly

Select
	Sum(Cast(total_cases As bigint)) As TotalCases
	, Sum(Convert(bigint, total_deaths)) As TotalDeaths
	, Sum(Convert(float, total_deaths))/Sum(Cast(total_cases As float))*100 As DeathPercentage
From CovidDataPractice..CovidDeaths
Where continent Is Not Null 
Order by 1



-- new_cases, new_deaths and death percentage globaly

Select
	Sum(new_cases) As TotalNewCases
	, Sum(new_deaths) As TotalNewDeaths
	, Sum(new_deaths)/Sum(new_cases)*100 As DeathPercentage
From CovidDataPractice..CovidDeaths
Where continent Is Not Null 
Having Sum(new_cases) > 0
Order by 1



-- population VS new_vaccination
-- Shows percentage of population that has recieved at least one covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition By dea.location Order By dea.date) As RollingVaccinationCount
From CovidDataPractice..CovidDeaths dea
Join CovidDataPractice..CovidVaccination vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent Is Not Null 
--And dea.location Like '%latvia%'
And vac.new_vaccinations Is Not Null --for easier visibility
Order By  1, 2, 3



-- Using CTE to perform Calculation on Partition By in previous query

With PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingVaccinationCount)
As
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition By dea.location Order By dea.date) As RollingVaccinationCount
	From CovidDataPractice..CovidDeaths dea
	Join CovidDataPractice..CovidVaccination vac
		On dea.location = vac.location
		And dea.date = vac.date
	Where dea.continent Is Not Null 
	--And dea.location Like '%latvia%'
	And vac.new_vaccinations Is Not Null	
)
Select *
	, (RollingVaccinationCount/Population)*100 AS RollingVaccinationPercentage
From PopVsVac
Order By  1, 2, 3



-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table If Exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(225), 
	Location nvarchar(225), 
	Date date, 
	Population bigint, 
	NewVaccinations bigint, 
	RollingVaccinationCount bigint
)

Insert Into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition By dea.location Order By dea.date) As RollingVaccinationCount
	From CovidDataPractice..CovidDeaths dea
	Join CovidDataPractice..CovidVaccination vac
		On dea.location = vac.location
		And dea.date = vac.date
	Where dea.continent Is Not Null
	And vac.new_vaccinations Is Not Null --for easier visibility

Select *
	, (RollingVaccinationCount/Cast(Population AS float))*100 AS RollingVaccinationPercentage
From #PercentPopulationVaccinated
Order By  1, 2, 3



-- Creating views for later visualization

Create View DeathsInContinent AS
Select Continent 
	, Max(Cast(total_deaths As int)) As TotalDeathCount
From CovidDataPractice..CovidDeaths
Where continent Is Not Null
Group By continent



Create View NewVaccinationCount AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, Sum(Convert(bigint, vac.new_vaccinations)) Over (Partition By dea.location Order By dea.date) As RollingVaccinationCount
From CovidDataPractice..CovidDeaths dea
Join CovidDataPractice..CovidVaccination vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent Is Not Null
And vac.new_vaccinations Is Not Null --for easier visibility

Select *
	, (RollingVaccinationCount/Cast(Population AS float))*100 AS RollingVaccinationPercentage
From NewVaccinationCount
Order By  1, 2, 3