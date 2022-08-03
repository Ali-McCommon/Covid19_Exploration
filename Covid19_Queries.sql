/*
Covid19 Data Exploration

Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT
  *
FROM
  `project-6389.Covid19_Info.deaths`
WHERE
  continent is NOT null
ORDER BY
  3,4

-- Selecting data to start with
SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM
  `project-6389.Covid19_Info.deaths`
ORDER BY
  1,2


-- Total Cases vs Total Deaths
-- The likelyhood of dying of Covid in the US
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 AS death_percentage
FROM
  `project-6389.Covid19_Info.deaths`
WHERE
  location = "United States"
ORDER BY
  death_percentage DESC


-- Total Cases vs Population
-- Showes what percentage of the US population got Covid
SELECT
  location,
  date,
  total_cases,
  population,
  (total_cases/population)*100 as percent_of_population_infected
FROM
 `project-6389.Covid19_Info.deaths`
WHERE
  location = "United States"
ORDER BY
  1,2


-- Contries Infection Rate Compared to Population
SELECT
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  MAX((total_cases/population))*100 as percent_of_population_infected
FROM
 `project-6389.Covid19_Info.deaths`
GROUP BY
  population, location
ORDER BY
  percent_of_population_infected DESC


-- Highest Death Count Per Population
SELECT
  location,
  MAX(cast(total_deaths as int)) as total_death_count
FROM
  `project-6389.Covid19_Info.deaths`
Where
  continent is not null
GROUP BY
  location
ORDER BY
  total_death_count DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Contients with the highest death count per population
SELECT
  continent,
  MAX(cast(total_deaths as int)) as total_death_count
FROM
  `project-6389.Covid19_Info.deaths`
Where
  continent is not null
GROUP BY
  continent
ORDER BY
  total_death_count 


-- GLOBAL NUMBERS
-- total global deaths per day
SELECT
  date, SUM(new_cases) AS global_deaths_per_day
FROM
  `project-6389.Covid19_Info.deaths`
WHERE
  continent is NOT null
GROUP BY
  date 
ORDER BY
  1,2


-- percent of all global deaths
SELECT
  SUM(new_cases) AS total_cases,
  SUM(CAST(new_deaths as int)) AS total_deaths,
  SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM
  `project-6389.Covid19_Info.deaths`
WHERE
  continent is NOT null
  

-- percent of global deaths per day
SELECT
  date,
  SUM(new_cases) AS total_cases,
  SUM(CAST(new_deaths as int)) AS total_deaths,
  SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM
  `project-6389.Covid19_Info.deaths`
WHERE
  continent is NOT null
Group By
  date
ORDER BY
  1,2

-- Total Population vs Vaccination
-- "new_vaccinations" are the new vaccinations per day
SELECT
  death.continent,
  death.location,
  death.date,
  death.population,
  vax.new_vaccinations
FROM
  `project-6389.Covid19_Info.deaths` AS death
JOIN
  `project-6389.Covid19_Info.vax` AS vax
  ON death.location = vax.location
  AND death.date = vax.date
WHERE
  death.continent is NOT null
ORDER BY
  2,3


-- Total Population vs Vaccination with Rolling Count
SELECT
  death.continent,
  death.location,
  death.date,
  death.population,
  vax.new_vaccinations,
  SUM
    (CAST(vax.new_vaccinations as int))
      OVER
        (PARTITION BY death.location ORDER BY death.location, death.date)
          as rolling_vax_count
FROM
  `project-6389.Covid19_Info.deaths` AS death
JOIN
  `project-6389.Covid19_Info.vax` AS vax
  ON death.location = vax.location
  AND death.date = vax.date
WHERE
  death.continent is NOT null
ORDER BY
  2,3


-- CTE to Perform Caculation on Pertition By Previous Query
-- NOTE: does not work on BigQuery so created a table manually
/*
WITH pop_vs_vax (continent, location, date, population, new_vaccinations, rolling_vax_count)
AS
(
  SELECT
    death.continent,
    death.location,
    death.date,
    death.population,
    vax.new_vaccinations,
    SUM
      (CAST(vax.new_vaccinations as int))
        OVER
          (PARTITION BY death.location ORDER BY death.location, death.date)
            as rolling_vax_count
  FROM
    `project-6389.Covid19_Info.deaths` AS death
  JOIN
    `project-6389.Covid19_Info.vax` AS vax
    ON death.location = vax.location
    AND death.date = vax.date
  WHERE
    death.continent is NOT null
)
SELECT
  *
FROM
  pop_vs_vax
*/



-- TEMP TABLE to Perform Caculation on Pertition By Previous Query
-- NOTE: does not work on BigQuery so created a table manually
/*
DROP Table if exists
  #Percent_Population_Vaccinated
CREATE TABLE
  #Percent_Population_Vaccinated
  (
    continent NVARCHAR(255),
    location NVARCHAR (255),
    date DATETIME,
    population NUMARIC,
    new_vaccinations NUMARIC,
    rolling_vax_count NUMARIC
  )
INSERT INTO
  #Percent_Population_Vaccinated
SELECT
  death.continent,
  death.location,
  death.date,
  death.population,
  vax.new_vaccinations,
  SUM
    (CAST(vax.new_vaccinations as int))
      OVER
        (PARTITION BY death.location ORDER BY death.location, death.date)
          as rolling_vax_count
FROM
  `project-6389.Covid19_Info.deaths` AS death
JOIN
  `project-6389.Covid19_Info.vax` AS vax
  ON death.location = vax.location
  AND death.date = vax.date
WHERE
  death.continent is NOT null
SELECT
  *,
  (rolling_vax_count/population)*100
FROM
  #Percent_Population_Vaccinated
*/

-- Creating a View for Visualization Later
--works but need the table to be created first

CREATE VIEW
Pop_vs_vax
  AS
    SELECT
      death.continent,
      death.location,
      death.date,
      death.population,
      vax.new_vaccinations,
      SUM
        (CAST(vax.new_vaccinations as int))
          OVER
            (PARTITION BY death.location ORDER BY death.location, death.date)
              as rolling_vax_count
    FROM
      `project-6389.Covid19_Info.deaths` AS death
    JOIN
      `project-6389.Covid19_Info.vax` AS vax
      ON death.location = vax.location
      AND death.date = vax.date
    WHERE
      death.continent is NOT null
