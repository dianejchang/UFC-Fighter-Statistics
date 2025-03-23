# Overview
This repository contains an in-depth analysis of UFC fighters across various weight classes. The goal is to identify attributes of top performing athletes that may contribute to their success compared to that of other fighters.

# Data Sources
Data was collected from ufcstats.com [by Asaniczka on Kaggle](https://www.kaggle.com/datasets/asaniczka/ufc-fighters-statistics/data).

# Tools & Technologies
- GitHub Pages for project hosting and SQL documentation
- PostgreSQL for SQL queries

# Project Structure
### SQL Queries: [Queried and analyzed UFC fighter statistics](https://github.com/dianejchang/UFC-Fighter-Statistics/blob/main/UFC%20Fighter%20Statistics%202024.sql) in PostgreSQL
1. Create Table
2. Add a new column due to 2 fighters with the same name
3. Concatenate names and id
4. Set primary key to concatenate
5. Counting the number of fighters in each weight class
6. Converting height and weight of fighters in each weight class
7. Calculating average reach advantage in each weight class
8. Calculating average significant striking accuracy in each weight class
9. Comparing average takedown accuracy for fighters in each weight class
10. Analyzing the average submission attempts across stances
11. Examining the offensive strikes vs takedowns between fighters with more than and less than 75% wins
12. Examining the defensive strikes vs takedowns between fighters with more than and less than 75% wins
13. Identifying fighters in each weight class with the best takedown defense, having had fought more than 15 total fights, and a 75+ percent success rate
14. Identifying the fighters with the longest reach in each weight class
15. Identifying the fighters with the shortest reach in each weight class
16. Determining the most common stance in each weight class

# Key Insights
- The lightweight class has the most number of fighters. Strawweight has the least number of fighters (as of Feb. 2024)
- Height and reach advantage on average is generally proportional to weight.
- The average significant strike accuracy is indirectly proportional to weight class, so the lighter athletes are more accurate in their significant strikes.
- The strawweight division has the highest takedown accuracy of 33.14% and the light heavyweight division has the lowest of 20.64%.
- Between those with a success rate of 75% or lower and those with a success rate of 75% or higher, the former performed better only in average takedowns landed per 15 minutes.
- It is generally believed that those with Southpaw (left-handed) or Switch (both left and right-handed) stances have an inherent advantage over those with an Orthodox (right-handed) stance since left-handedness and ambidexterity are not as common as right-handedness. However, results show that it made no statistical impact on win rates.

# About Me
My name is Diane Chang and I am a data analyst with 9+ years experience transforming data into actionable insights.

At my core, I am an investigator. I dig deep and connect the dots to extract meaningful insights, enabling teams to make informed decisions. I excel at cataloging information to help visualize complex problems, creating colorful dashboards, and obsessing over details that can drive strategic decisions.

#### [Let's connect on LinkedIn!](https://www.linkedin.com/in/dianejchang/)
