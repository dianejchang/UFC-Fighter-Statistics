CREATE TABLE public."ufc_stats"(person_name varchar(100),nickname varchar(100),wins float,losses float,draws float,height_cm float,weight_in_kg float,reach_in_cm float,
								stance varchar(100),date_of_birth varchar(100),significant_strikes_landed_per_minute float,
								significant_striking_accuracy float,significant_strikes_absorbed_per_minute float,significant_strike_defence float,
								average_takedowns_landed_per_15_minutes float,takedown_accuracy float,takedown_defense float,
								average_submissions_attempted_per_15_minutes float)
;


-- Since there are two Tony Johnsons, add column in order to create primary key
ALTER TABLE ufc_stats
ADD COLUMN id SERIAL PRIMARY KEY
;


-- Concat person_name and id columns
UPDATE ufc_stats AS t1
SET person_name = 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM ufc_stats AS t2 
            WHERE t2.person_name = t1.person_name
        ) THEN CONCAT(person_name, ' ', id)
        ELSE person_name
    END
;


-- Set primary key
ALTER TABLE ufc_stats
ADD COLUMN id SERIAL PRIMARY KEY,
ADD CONSTRAINT pk_my_table UNIQUE (person_name)
;


-- Counting the number of fighters in each weight class
SELECT COUNT(CASE WHEN weight_in_kg <= 52.54 THEN 1 ELSE NULL END) AS Strawweight_115,
		COUNT(CASE WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN 1 ELSE NULL END) AS Flyweight_125,
		COUNT(CASE WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN 1 ELSE NULL END) AS Bantamweight_135,
		COUNT(CASE WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN 1 ELSE NULL END) AS Featherweight_145,
		COUNT(CASE WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN 1 ELSE NULL END) AS Lightweight_155,
		COUNT(CASE WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN 1 ELSE NULL END) AS Welterweight_170,
		COUNT(CASE WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN 1 ELSE NULL END) AS Middleweight_185,
		COUNT(CASE WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN 1 ELSE NULL END) AS Light_Heavyweight_205,
		COUNT(CASE WHEN weight_in_kg >= 102.15 THEN 1 ELSE NULL END) AS Heavyweight_265
FROM ufc_stats
;


-- Average height and weight of fighters in each weight class (converted unit of measure from cm to ft and in and kg to lbs)
-- I separated two groups where the average fighter height starts with 5 foot and starts with 6 foot to make reading and interpreting heights easier
	SELECT CASE WHEN weight_in_kg <= 52.54 THEN 'Strawweight_115'
				WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN 'Flyweight_125'
				WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN 'Bantamweight_135'
				WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN 'Featherweight_145'
				WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN 'Lightweight_155'
				WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN 'Welterweight_170'
					END AS weight_class_division,
			FLOOR((AVG(height_cm)/2.54)/12) AS avg_height_in_ft, ROUND((((AVG(height_cm)/2.54)/12)-5)*12) AS avg_height_in_in, ROUND(AVG(weight_in_kg*2.204623)) AS avg_weight_in_lb
	FROM ufc_stats
	WHERE weight_in_kg <= 77.14
	GROUP BY weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN 'Middleweight_185'
				WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN 'Light_Heavyweight_205'
				WHEN weight_in_kg >= 102.15 THEN 'Heavyweight_265'
					END AS weight_class_division,
			FLOOR((AVG(height_cm)/2.54)/12) AS avg_height_in_ft, ROUND((((AVG(height_cm)/2.54)/12)-6)*12) AS avg_height_in_in, ROUND(AVG(weight_in_kg*2.204623)) AS avg_weight_in_lb
	FROM ufc_stats
	WHERE weight_in_kg >= 77.15
	GROUP BY weight_class_division
	ORDER BY avg_weight_in_lb
;


-- Calculating the average reach advantage of fighters in each weight class
SELECT CASE WHEN weight_in_kg <= 52.54 THEN '115_Strawweight'
			WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN '125_Flyweight'
			WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN '135_Bantamweight'
			WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN '145_Featherweight'
			WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN '155_Lightweight'
			WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN '170_Welterweight'
			WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN '185_Middleweight'
			WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN '205_Light_Heavyweight'
			WHEN weight_in_kg >= 102.15 THEN '265_Heavyweight'
				END AS weight_class_division,
		AVG(reach_in_cm - height_cm)/2.54 AS reach_advantage_in_in
FROM ufc_stats
WHERE reach_in_cm IS NOT NULL
GROUP BY weight_class_division
ORDER BY weight_class_division
;


-- Calculating the average significant striking accuracy for fighters in each weight class
SELECT CASE WHEN weight_in_kg <= 52.54 THEN '115_Strawweight'
			WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN '125_Flyweight'
			WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN '135_Bantamweight'
			WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN '145_Featherweight'
			WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN '155_Lightweight'
			WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN '170_Welterweight'
			WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN '185_Middleweight'
			WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN '205_Light_Heavyweight'
			WHEN weight_in_kg >= 102.15 THEN '265_Heavyweight'
				END AS weight_class_division,
		AVG(significant_striking_accuracy) AS average_significant_striking_accuracy
FROM ufc_stats
WHERE weight_in_kg IS NOT NULL
GROUP BY weight_class_division
ORDER BY average_significant_striking_accuracy DESC
;


-- Comparing average takedown accuracy for fighters in each weight class
SELECT CASE WHEN weight_in_kg <= 52.54 THEN '115_Strawweight'
			WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN '125_Flyweight'
			WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN '135_Bantamweight'
			WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN '145_Featherweight'
			WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN '155_Lightweight'
			WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN '170_Welterweight'
			WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN '185_Middleweight'
			WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN '205_Light_Heavyweight'
			WHEN weight_in_kg >= 102.15 THEN '265_Heavyweight'
				END AS weight_class_division,
		AVG(takedown_accuracy) AS average_takedown_accuracy
FROM ufc_stats
WHERE weight_in_kg IS NOT NULL AND takedown_accuracy IS NOT NULL
GROUP BY weight_class_division
ORDER BY weight_class_division
;


-- Analyze the average submission attempts across stances
SELECT stance,	AVG(average_submissions_attempted_per_15_minutes) AS average_submissions_attempted_per_15_minutes
FROM ufc_stats
WHERE stance IS NOT NULL
GROUP BY stance
ORDER BY average_submissions_attempted_per_15_minutes
;



-- Examine the differences between fighters with less than 75 percent success rate and those with 75+ percent success rate
-- Offense: Strikes vs. Takedowns
	SELECT COUNT(person_name), AVG((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, AVG(significant_strikes_landed_per_minute) AS avg_significant_strikes_landed_per_minute, 
		AVG(significant_striking_accuracy) AS avg_significant_striking_accuracy, AVG(average_takedowns_landed_per_15_minutes) AS avg_average_takedowns_landed_per_15_minutes,
		AVG(takedown_accuracy) AS avg_takedown_accuracy, AVG(average_submissions_attempted_per_15_minutes) AS avg_average_submissions_attempted_per_15_minutes
	FROM ufc_stats
	WHERE (reach_in_cm - height_cm) IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) < 75
UNION
	SELECT COUNT(person_name), AVG((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, AVG(significant_strikes_landed_per_minute) AS avg_significant_strikes_landed_per_minute, 
		AVG(significant_striking_accuracy) AS avg_significant_striking_accuracy, AVG(average_takedowns_landed_per_15_minutes) AS avg_average_takedowns_landed_per_15_minutes,
		AVG(takedown_accuracy) AS avg_takedown_accuracy, AVG(average_submissions_attempted_per_15_minutes) AS avg_average_submissions_attempted_per_15_minutes
	FROM ufc_stats
	WHERE (reach_in_cm - height_cm) IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	ORDER BY success_rate DESC
;


-- Defense: Strikes vs. Takedowns
	SELECT COUNT(person_name), AVG((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, AVG(significant_strikes_absorbed_per_minute) AS avg_significant_strikes_absorbed_per_minute,
		AVG(significant_strike_defence) AS avg_significant_strike_defence, AVG(takedown_defense) AS average_takedown_defense
	FROM ufc_stats
	WHERE (reach_in_cm - height_cm) IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) < 75
UNION
	SELECT COUNT(person_name), AVG((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, AVG(significant_strikes_absorbed_per_minute) AS avg_significant_strikes_absorbed_per_minute,
		AVG(significant_strike_defence) AS avg_significant_strike_defence, AVG(takedown_defense) AS average_takedown_defense
	FROM ufc_stats
	WHERE (reach_in_cm - height_cm) IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	ORDER BY success_rate DESC
;


-- Identify fighters in each weight class with the best takedown defense, having had fought more than 15 total fights, and a 75+ percent success rate
	SELECT CASE WHEN weight_in_kg <= 52.54 THEN '115_Strawweight' END AS weight_class_division, person_name, nickname, ((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, 
		(wins + losses + draws) AS total_fights, takedown_defense
	FROM ufc_stats
	WHERE weight_in_kg <= 52.54 AND takedown_defense >= 75 AND (wins + losses + draws) > 15 AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	GROUP BY person_name, nickname, wins, losses, draws, weight_in_kg, takedown_defense
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN '125_Flyweight' END AS weight_class_division, person_name, nickname, 
		((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, (wins + losses + draws) AS total_fights, takedown_defense
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 52.55 AND 56.74 AND takedown_defense >= 75 AND (wins + losses + draws) > 15 AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	GROUP BY person_name, nickname, wins, losses, draws, weight_in_kg, takedown_defense
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN '135_Bantamweight' END AS weight_class_division, person_name, nickname, 
		((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, (wins + losses + draws) AS total_fights, takedown_defense
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 56.75 AND 61.24 AND takedown_defense >= 75 AND (wins + losses + draws) > 15 AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	GROUP BY person_name, nickname, wins, losses, draws, weight_in_kg, takedown_defense
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN '145_Featherweight' END AS weight_class_division, person_name, nickname, 
		((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, (wins + losses + draws) AS total_fights, takedown_defense
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 61.25 AND 65.84 AND takedown_defense >= 75 AND (wins + losses + draws) > 15 AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	GROUP BY person_name, nickname, wins, losses, draws, weight_in_kg, takedown_defense
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN '155_Lightweight' END AS weight_class_division, person_name, nickname, 
		((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, (wins + losses + draws) AS total_fights, takedown_defense
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 65.85 AND 70.34 AND takedown_defense >= 75 AND (wins + losses + draws) > 15 AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	GROUP BY person_name, nickname, wins, losses, draws, weight_in_kg, takedown_defense
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN '170_Welterweight' END AS weight_class_division, person_name, nickname, 
		((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, (wins + losses + draws) AS total_fights, takedown_defense
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 70.35 AND 77.14 AND takedown_defense >= 75 AND (wins + losses + draws) > 15 AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	GROUP BY person_name, nickname, wins, losses, draws, weight_in_kg, takedown_defense
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN '185_Middleweight' END AS weight_class_division, person_name, nickname, 
		((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, (wins + losses + draws) AS total_fights, takedown_defense
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 77.15 AND 83.94 AND takedown_defense >= 75 AND (wins + losses + draws) > 15 AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	GROUP BY person_name, nickname, wins, losses, draws, weight_in_kg, takedown_defense
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN '205_Light_Heavyweight' END AS weight_class_division, person_name, nickname, 
		((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, (wins + losses + draws) AS total_fights, takedown_defense
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 83.95 AND 102.14 AND takedown_defense >= 75 AND (wins + losses + draws) > 15 AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	GROUP BY person_name, nickname, wins, losses, draws, weight_in_kg, takedown_defense
UNION
	SELECT CASE WHEN weight_in_kg >= 102.15 THEN '265_Heavyweight' END AS weight_class_division, person_name, nickname, 
		((wins/NULLIF((wins + losses + draws), 0))*100) AS success_rate, (wins + losses + draws) AS total_fights, takedown_defense
	FROM ufc_stats
	WHERE weight_in_kg >= 102.15 AND takedown_defense >= 75 AND (wins + losses + draws) > 15 AND ((wins/NULLIF((wins + losses + draws), 0))*100) >= 75
	GROUP BY person_name, nickname, wins, losses, draws, weight_in_kg, takedown_defense
	ORDER BY weight_class_division, takedown_defense DESC
;


-- Identify the fighters with the longest reach in each weight class
	SELECT CASE WHEN weight_in_kg <= 52.54 THEN '115_Strawweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg <= 52.54 AND reach_in_cm = (SELECT MAX(reach_in_cm)
												   FROM ufc_stats
												   WHERE weight_in_kg <= 52.54)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN '125_Flyweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 52.55 AND 56.74 AND reach_in_cm = (SELECT MAX(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 52.55 AND 56.74)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN '135_Bantamweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 56.75 AND 61.24 AND reach_in_cm = (SELECT MAX(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 56.75 AND 61.24)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN '145_Featherweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 61.25 AND 65.84 AND reach_in_cm = (SELECT MAX(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 61.25 AND 65.84)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN '155_Lightweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 65.85 AND 70.34 AND reach_in_cm = (SELECT MAX(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 65.85 AND 70.34)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN '170_Welterweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 70.35 AND 77.14 AND reach_in_cm = (SELECT MAX(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 70.35 AND 77.14)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN '185_Middleweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 77.15 AND 83.94 AND reach_in_cm = (SELECT MAX(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 77.15 AND 83.94)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN '205_Light_Heavyweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 83.95 AND 102.14 AND reach_in_cm = (SELECT MAX(reach_in_cm)
																   FROM ufc_stats
																   WHERE weight_in_kg BETWEEN 83.95 AND 102.14)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg >= 102.15 THEN '265_Heavyweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg >= 102.15 AND reach_in_cm = (SELECT MAX(reach_in_cm)
													FROM ufc_stats
													WHERE weight_in_kg >= 102.15)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
	ORDER BY weight_class_division
;


-- Identify the fighters with the shortest reach in each weight class
	SELECT CASE WHEN weight_in_kg <= 52.54 THEN '115_Strawweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg <= 52.54 AND reach_in_cm = (SELECT MIN(reach_in_cm)
												   FROM ufc_stats
												   WHERE weight_in_kg <= 52.54)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN '125_Flyweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 52.55 AND 56.74 AND reach_in_cm = (SELECT MIN(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 52.55 AND 56.74)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN '135_Bantamweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 56.75 AND 61.24 AND reach_in_cm = (SELECT MIN(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 56.75 AND 61.24)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN '145_Featherweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 61.25 AND 65.84 AND reach_in_cm = (SELECT MIN(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 61.25 AND 65.84)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN '155_Lightweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 65.85 AND 70.34 AND reach_in_cm = (SELECT MIN(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 65.85 AND 70.34)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN '170_Welterweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 70.35 AND 77.14 AND reach_in_cm = (SELECT MIN(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 70.35 AND 77.14)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN '185_Middleweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 77.15 AND 83.94 AND reach_in_cm = (SELECT MIN(reach_in_cm)
																  FROM ufc_stats
																  WHERE weight_in_kg BETWEEN 77.15 AND 83.94)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN '205_Light_Heavyweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 83.95 AND 102.14 AND reach_in_cm = (SELECT MIN(reach_in_cm)
																   FROM ufc_stats
																   WHERE weight_in_kg BETWEEN 83.95 AND 102.14)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
UNION
	SELECT CASE WHEN weight_in_kg >= 102.15 THEN '265_Heavyweight' END AS weight_class_division, person_name, nickname, reach_in_cm/2.54 AS reach_in_in
	FROM ufc_stats
	WHERE weight_in_kg >= 102.15 AND reach_in_cm = (SELECT MIN(reach_in_cm)
													FROM ufc_stats
													WHERE weight_in_kg >= 102.15)
	GROUP BY person_name, nickname, weight_in_kg, reach_in_cm
	ORDER BY weight_class_division
;


-- Determine the  most common stance within each weight class to see if there are more prevalent stances in each division
	SELECT CASE WHEN weight_in_kg <= 52.54 THEN '115_Strawweight' END AS weight_class_division, stance, COUNT(stance) AS number_of_fighters_with_X_stance
	FROM ufc_stats
	WHERE weight_in_kg <= 52.54 AND stance IS NOT NULL
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN '125_Flyweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 52.55 AND 56.74 AND stance IS NOT NULL
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN '135_Bantamweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 56.75 AND 61.24  AND stance IS NOT NULL
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN '145_Featherweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 61.25 AND 65.84 AND stance IS NOT NULL
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN '155_Lightweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 65.85 AND 70.34 AND stance IS NOT NULL
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN '170_Welterweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 70.35 AND 77.14 AND stance IS NOT NULL
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN '185_Middleweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 77.15 AND 83.94 AND stance IS NOT NULL
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN '205_Light_Heavyweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 83.95 AND 102.14 AND stance IS NOT NULL
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg >= 102.15 THEN '265_Heavyweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg >= 102.15 AND stance IS NOT NULL
	GROUP BY stance, weight_class_division
	ORDER BY weight_class_division, stance
;


-- Determine the  most common stance within each weight class AMONG FIGHTERS WITH OVER 75% WINS to see if there are more prevalent stances in each division
	SELECT CASE WHEN weight_in_kg <= 52.54 THEN '115_Strawweight' END AS weight_class_division, stance, COUNT(stance) AS number_of_fighters_with_X_stance
	FROM ufc_stats
	WHERE weight_in_kg <= 52.54 AND stance IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) > 75
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 52.55 AND 56.74 THEN '125_Flyweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 52.55 AND 56.74 AND stance IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) > 75
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 56.75 AND 61.24 THEN '135_Bantamweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 56.75 AND 61.24  AND stance IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) > 75
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 61.25 AND 65.84 THEN '145_Featherweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 61.25 AND 65.84 AND stance IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) > 75
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 65.85 AND 70.34 THEN '155_Lightweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 65.85 AND 70.34 AND stance IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) > 75
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 70.35 AND 77.14 THEN '170_Welterweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 70.35 AND 77.14 AND stance IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) > 75
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 77.15 AND 83.94 THEN '185_Middleweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 77.15 AND 83.94 AND stance IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) > 75
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg BETWEEN 83.95 AND 102.14 THEN '205_Light_Heavyweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg BETWEEN 83.95 AND 102.14 AND stance IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) > 75
	GROUP BY stance, weight_class_division
UNION
	SELECT CASE WHEN weight_in_kg >= 102.15 THEN '265_Heavyweight' END AS weight_class_division, stance, COUNT(stance)
	FROM ufc_stats
	WHERE weight_in_kg >= 102.15 AND stance IS NOT NULL AND ((wins/NULLIF((wins + losses + draws), 0))*100) > 75
	GROUP BY stance, weight_class_division
	ORDER BY stance, weight_class_division
;
