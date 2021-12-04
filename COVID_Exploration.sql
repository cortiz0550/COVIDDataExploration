SELECT *
FROM
	[Portfolio Project]..covidDeaths
ORDER BY
	3,4

--SELECT *
--FROM
--	[Portfolio Project]..covidVaccinations
--ORDER BY
--	3,4

-- Select the data that we are going to be using

SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	[Portfolio Project]..covidDeaths
WHERE
	continent IS NOT Null
ORDER BY
	1,2;

-- Looking at total cases vs. total deaths
-- Shows likelihood of dying if you catch COVID in your country
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths / total_cases) * 100 AS death_rate
FROM
	[Portfolio Project]..covidDeaths
WHERE
	location like '%states%'
	AND
		continent IS NOT Null
ORDER BY
	1,2;

-- Looking at total cases vs. population

SELECT
	location,
	date,
	total_cases,
	population,
	(total_cases / population) * 100 AS cases_vs_pop
FROM
	[Portfolio Project]..covidDeaths
WHERE
	location = 'United States'
	AND
		continent IS NOT Null
ORDER BY
	1,2;

-- Looking at countries with highest infection compared to population

SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	(MAX(total_cases) / population) * 100 AS percent_pop_infected
FROM
	[Portfolio Project]..covidDeaths
WHERE
	continent IS NOT Null
GROUP BY
	location, population
ORDER BY
	4 DESC;

-- Highest death count per population

SELECT
	location,
	MAX(CAST(total_deaths AS int)) AS total_death_count
FROM
	[Portfolio Project]..covidDeaths
WHERE
	continent IS NOT Null
GROUP BY
	location
ORDER BY
	total_death_count DESC;

-- Looking by continent

SELECT
	location,
	MAX(CAST(total_deaths AS int)) AS total_death_count
FROM
	[Portfolio Project]..covidDeaths
WHERE
	continent IS Null
	AND
		location IN ('North America', 'Asia', 'Africa',	'South America', 'Europe', 'Oceania')
GROUP BY
	location
ORDER BY
	total_death_count DESC;

-- Global numbers

SELECT
	--date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	 SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS death_rate
FROM
	[Portfolio Project]..covidDeaths
WHERE
	continent IS NOT Null
--GROUP BY
--	date
ORDER BY
	1,2;


-- Looking at total population vs vaccinations

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) 
		OVER (
			PARTITION BY dea.location 
				ORDER BY dea.location, dea.date) AS rolling_ppl_vaccinated
FROM [Portfolio Project]..covidDeaths AS dea
JOIN [Portfolio Project]..covidVaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY
	2, 3;


-- Use cte

WITH pop_vs_vac(continent, location, date, population, new_vaccinations, rolling_ppl_fully_vaccinated)
AS (
	SELECT 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.people_fully_vaccinated)) 
			OVER (
				PARTITION BY dea.location 
					ORDER BY dea.location, dea.date) AS rolling_ppl_fully_vaccinated
	FROM [Portfolio Project]..covidDeaths AS dea
	JOIN [Portfolio Project]..covidVaccinations AS vac
	ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	AND dea.location = 'United States'
	--ORDER BY
	--	2, 3
)

SELECT *, (rolling_ppl_fully_vaccinated / population) * 100
FROM pop_vs_vac;
