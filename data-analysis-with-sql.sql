/*
Name: Austin Gae

Project Purpose: To understand the COVID-19 dataset, ask questions and find answers based on the dataset, and find correlations between two variables. 

Structure Of This Project: This SQL project is divided into 3 parts: 1) this part clears up some confusion I had with the dataset. 2) this part asked some general questions with insightful answers of the dataset 3) this part identified whether correlation exist between two variables from the dataset.

Metadata on the Dataset: 
  Name: Our World in Data COVID-19 dataset
  Date Created: 2020
  Frequency of Updates: Updated daily
  Creators: Edouard Mathieu, Hannah Ritchie, Lucas Rodés-Guirao, Cameron Appel, Daniel Gavrilov, Charlie Giattino, Joe Hasell, Bobbie Macdonald, Saloni Dattani, Diana Beltekian, Esteban Ortiz-Ospina, and Max Roser at the Our World in Data organization
  Link: https://ourworldindata.org/covid-deaths
*/



-- PART 1: Clearing up some confusion of the COVID-19 dataset.

-- Question: How many rows exist in this dataset?
-- Answer: About 250,000 rows.
SELECT 
  COUNT(iso_code)
FROM covid_data.covid_data

-- Question: What are the distinct values in continent column? 
-- Answer: There are six: Asia, Africa, Europe, Oceania, NA, SA
SELECT
  DISTINCT(continent)
FROM 
  covid_data.covid_data
WHERE
  continent IS NOT NULL

-- Question: What does the location column mean?
-- Answer: Location column has the list of countries. 
SELECT
  DISTINCT(location)
FROM 
  covid_data.covid_data
WHERE 
  continent IS NOT NULL 
ORDER BY
  location ASC

-- PART 2: Asking some general questions of the COVID-19 dataset.

-- Question: How many worldwide COVID-19 cases exist? 
-- Answer: About 672 million cases.
SELECT
  SUM(CAST(new_cases AS INT64)) as worldwide_covid_19_cases
FROM
  covid_data.covid_data
WHERE
  continent IS NOT NULL

-- Question: How many worldwide COVID-19 deaths exist? 
-- Answer: About 6.8 million deaths.
SELECT
  SUM(CAST(new_deaths AS INT64)) as worldwide_covid_19_deaths
FROM
  covid_data.covid_data
WHERE 
  continent IS NOT NULL

-- Question: What is the percentage of worldwide COVID-19 death rate?
-- Answer: 0.99%.
SELECT
  ((SUM(new_deaths)/SUM(new_cases)) * 100) as worldwide_death_percentage
FROM
  covid_data.covid_data

-- Questions: How many COVID-19 worldwide cases per year? How many COVID-19 worldwide deaths per year?
-- Answer: Run this SQL query to create a table that has the answers.
SELECT
  CAST(EXTRACT(year FROM date) as INT64) as year, --Extract function to retrieve year from date format; then cast the year as type INT64
  SUM(CAST(new_cases as INT64)) as covid_19_worldwide_cases,
  SUM(CAST(new_deaths as INT64)) as covid_19_worldwide_deaths
FROM
  covid_data.covid_data
WHERE
  continent IS NOT NULL
GROUP BY
  1 -- Group by year from 2020 to 2023
ORDER BY
  1 ASC -- Order by year in ascending order, so starting from 2020 to 2023

-- Question: How many total hospital admissions from COVID-19?
-- Answer: 95,546,126 million hospital admissions.
SELECT
  SUM(CAST(weekly_hosp_admissions AS FLOAT64)) as total_worldwide_hospital_admissions
FROM covid_data.covid_data
WHERE
  weekly_hosp_admissions IS NOT NULL AND continent IS NOT NULL

-- Question: How many COVID-19 vaccinations per year from 2020 to 2023?
-- Answer: Run this SQL query to get a table that has the answers.
SELECT
  EXTRACT(year FROM date) as year,
  SUM(new_vaccinations) as total_worldwide_vaccinations
FROM
  covid_data.covid_data
WHERE 
  continent IS NOT NULL
GROUP BY
  1
ORDER BY
  1 ASC

-- Question: What are the top 5 countries that have the highest vaccination rate compared to their population?
-- Answer: Gibraltar, Tokelau, Qatar, United Arab Emirates, and Pitcairn
SELECT
  location,
  ((MAX(people_fully_vaccinated)/MAX(population)) * 100) as vaccination_rate
FROM
  covid_data.covid_data
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  2 DESC
LIMIT
  5

/* Question: What percentage of the US population has gotten covid-19,
   been hospitalized for covid-19, died to covid-19, been fully vaccinated compared
   to the population? */
/* Answer:
    In the United States, covid-19 percentage is 30%; hospitalization percentage is 13%, death_percentage is 0.33%, and fully_vaccinated_people percentage is 68% compared to its total population of about 338 million.
*/
SELECT
  location, --the US
  CAST(AVG(population) as INT64) as total_population,
  CAST((SUM(new_cases)/AVG(population)) * 100 as INT64) as covid19_percentage, 
  CAST(((SUM(CAST(weekly_hosp_admissions AS FLOAT64))/AVG(population)) * 100) as INT64) as hospitalization_percentage,
  ROUND((CAST((SUM(new_deaths)/AVG(population)) * 100 as FLOAT64)),2) as death_percentage,
  CAST((MAX(people_fully_vaccinated)/AVG(population)) * 100 as INT64) as fully_vaccinated_percentage
FROM
  covid_data.covid_data
WHERE
  continent IS NOT NULL AND location = "United States"
GROUP BY
  location

/*
  Question: What's the covid19_percentage, hospitalization_percentage, death_percentage, and fully_vaccinated_percentage for the top 10 countries with the highest GDP?
*/
/*
  Answer: Run the SQL query to get the table that has the answers. 
*/
SELECT
  location,
  CAST(AVG(population) as INT64) as total_population,
  CAST((SUM(new_cases)/AVG(population)) * 100 as INT64) as covid19_percentage, 
  CAST(((SUM(CAST(weekly_hosp_admissions AS FLOAT64))/AVG(population)) * 100) as INT64) as hospitalization_percentage,
  ROUND((CAST((SUM(new_deaths)/AVG(population)) * 100 as FLOAT64)),2) as death_percentage,
  CAST((MAX(people_fully_vaccinated)/AVG(population)) * 100 as INT64) as fully_vaccinated_percentage
FROM
  covid_data.covid_data
WHERE
  continent IS NOT NULL AND (location = "United States" OR location = "China" OR location = "Japan" OR location = "Germany" OR location = "United Kingdom" OR location = "India" OR location = "France" OR location = "Italy" OR location = "Canada" OR location = "South Korea")
GROUP BY
  location
ORDER BY
  5 DESC

-- Question: With the COVID-19 pandemic, has the average global life expectancy from 2020 to 2023 increased or decreased?
-- Answer: Average life expectancy has decreased some decimal points every year. In 2020, average life expectancy was 73.851. In 2023, that number is 73.421.
SELECT
  EXTRACT(year FROM date) as year,
  ROUND(AVG(life_expectancy), 3) as average_life_expectancy
FROM 
  covid_data.covid_data
WHERE
  continent IS NOT NULL
GROUP BY
  1
ORDER BY
  1 ASC

-- Question: As COVID-19 winds down, what are the top 5 countries with the highest life expectancy in 2023?
-- Answer: The top 5 countries are Monaco, San Marino, Japan, Switzerland, and Andorra.  
SELECT
  location,
  AVG(life_expectancy) as life_expectancy_in_2023
FROM
  covid_data.covid_data
WHERE
  continent IS NOT NULL AND EXTRACT(year FROM date) = 2023
GROUP BY
  location
ORDER BY
  2 DESC

-- PART 3: Identifying correlations between two variables in the COVID-19 dataset. 

-- Question: Is there a correlation between gdp_per_capita and vaccination_rate? 
-- Answer: Well, sort of. A Pearson correlation coefficient of 0.59 shows that there is some degree of correlation between the two variables.
SELECT
  CORR(vaccination_rate, gdp_per_capita)
FROM
  (SELECT
    location,
    ((MAX(people_fully_vaccinated)/AVG(population)) * 100) as vaccination_rate,
    AVG(gdp_per_capita) as gdp_per_capita
  FROM
    covid_data.covid_data
  WHERE
    continent IS NOT NULL
  GROUP BY
    location
  ORDER BY
    3 DESC
  )

-- Question: Is there a correlation between gdp_per_capita and the number of hospital beds per one thousand?
-- Prediction:  There is some degree of correlation -- I would guess about .65. My reasoning is that the richer a country, the more hospital beds it should be able to afford. 
-- Answer: The result is actually surprising -- the correlation_coefficient is 0.29! This means that there is little correlation between the two variables. 
SELECT
  CORR(hospital_beds_per_one_thousand, gdp_per_capita) as correlation_coefficient
FROM
  (SELECT
    location,
    AVG(hospital_beds_per_thousand) as hospital_beds_per_one_thousand,
    AVG(gdp_per_capita) as gdp_per_capita
  FROM
    covid_data.covid_data
  WHERE
    continent IS NOT NULL
  GROUP BY
    location
  )

-- Question: Is there a correlation between gdp_per_capita and covid_19_death_rate by country?
-- Prediction: I feel like the Pearson coefficient would be like -0.50. The correlation would be opposite. 
-- Answer: The Pearson correlation coefficient is 0.24. 
SELECT
  CORR(gdp_per_capita, death_rate) as coefficient
FROM 
  (SELECT
    location,
    AVG(gdp_per_capita) as gdp_per_capita,
    (MAX(total_deaths)/AVG(population) * 100) as death_rate
  FROM
    covid_data.covid_data
  WHERE
    continent IS NOT NULL
  GROUP BY
    location
  ORDER BY
    3 DESC)



