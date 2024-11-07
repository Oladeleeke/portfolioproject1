
-- Looking at the Ratio of total cases to total deaths by country. eg the united states

SELECT location, date, total_cases, total_deaths, 
       (total_deaths::float / total_cases) * 100 AS deathpercentage
FROM covid_death
WHERE location = 'United Kingdom'
ORDER BY 1, 2;

-- Total cases versus the population
-- shows the % of population that had covid 

SELECT location, date, population, total_cases,
       (total_cases::float / population) * 100 AS percentofinfected
FROM covid_death
WHERE location = 'United Kingdom'
ORDER BY 1, 2;

-- countries with hightest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infectioncount,
       MAX((total_cases::float / population)) * 100 AS percentpopulationinfected
FROM covid_death
WHERE total_cases IS NOT NULL
GROUP BY location, population
ORDER BY percentpopulationinfected DESC;

-- countries with the highest mortality rate 
SELECT location, MAX(total_deaths) AS highest_mortality
FROM covid_death
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY highest_mortality DESC;

--continents with the highest mortality rate 
SELECT continent, MAX(total_deaths) AS highest_mortality
FROM covid_death
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY continent
ORDER BY highest_mortality DESC;

--OR 
SELECT location, MAX(total_deaths) AS highest_mortality
FROM covid_death
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY highest_mortality DESC;

--GLOBAL NUMBERS PER DAY


SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)::float / SUM(new_cases) * 100 AS deathpercentage
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


Total population that was vaccinated

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingcount_newvaccinations
FROM covid_death cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL --AND new_vaccinations IS NOT NULL
ORDER BY 2,3;



--USE CTE TO FIND THE PERCENTAGE OF THE POPULATION THAT HAS BEEN VACCINATED ON A ROLLING BASIS

WITH vac_populaiton (continent, location, date, population, new_vaccinations, rollingcount_newvaccinations)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingcount_newvaccinations
FROM covid_death cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL --AND new_vaccinations IS NOT NULL
--ORDER BY 2,3;
)
SELECT *, (rollingcount_newvaccinations::FLOAT/population)*100 AS
FROM vac_populaiton

--Creating view to store data for visualization

CREATE VIEW percentpopulationvaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingcount_newvaccinations
FROM covid_death cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL --AND new_vaccinations IS NOT NULL
--ORDER BY 2,3;