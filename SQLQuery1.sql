-- 1 --- Q1) Extract P_ID,Dev_ID,PName and Difficulty_level of all players 
-- at level 0
SELECT p.P_ID, l.Dev_ID, p.PName, l.difficulty AS Difficulty_level
FROM player_details p
JOIN level_details2 l ON p.P_ID = l.P_ID
WHERE l.level = 0;

-- 2
SELECT Level, AVG(kill_count) AS Avg_Kill_Count
FROM level_details2
WHERE lives_earned = 2 AND stages_crossed >= 3
GROUP BY Level;

-- 3
SELECT Difficulty, SUM(Stages_crossed) AS Total_Stages_Crossed
FROM level_details2
WHERE Level = 2 AND Dev_ID LIKE 'zm%'
GROUP BY Difficulty
ORDER BY Total_Stages_Crossed DESC;

-- 4
SELECT P_ID, COUNT(DISTINCT CONVERT(date, StartDate)) AS Unique_Dates
FROM level_details2
GROUP BY P_ID
HAVING COUNT(DISTINCT CONVERT(date, StartDate)) > 1;

-- 5
WITH AvgKillCount AS (
    SELECT AVG(kill_count) AS Avg_Kill_Count
    FROM level_details2
    WHERE difficulty = 'Medium'
)

SELECT l.P_ID, l.level, SUM(l.kill_count) AS Total_Kill_Count
FROM level_details2 l, AvgKillCount a
WHERE l.difficulty = 'Medium' 
AND l.kill_count > a.Avg_Kill_Count
GROUP BY l.P_ID, l.level;

-- 6
SELECT level, p.L1_code, SUM(lives_earned) AS Total_Lives_Earned
FROM level_details2 l
JOIN player_details p ON l.P_ID = p.P_ID
WHERE level <> 0
GROUP BY level, p.L1_code
ORDER BY level ASC;

-- 7
WITH RankedScores AS (
    SELECT Dev_ID, difficulty, score,
           ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY score DESC) AS Rank
    FROM level_details2
)

SELECT Dev_ID, difficulty, score
FROM RankedScores
WHERE Rank <= 3
ORDER BY Score DESC, Rank ASC;

-- 8
SELECT Dev_ID, MIN(StartDate) AS first_login_datetime
FROM level_details2
GROUP BY Dev_ID;

-- 9
WITH RankedScores AS (
    SELECT Dev_ID, difficulty, score,
           ROW_NUMBER() OVER (PARTITION BY difficulty ORDER BY score DESC) AS Rank
    FROM level_details2
)

SELECT Dev_ID, difficulty, score
FROM RankedScores
WHERE Rank <= 5
ORDER BY difficulty ASC, Rank ASC;
-- 10
SELECT l.P_ID, l.Dev_ID, l.StartDate AS first_login_datetime
FROM level_details2 l
INNER JOIN (
    SELECT P_ID, MIN(StartDate) AS min_start_time
    FROM level_details2
    GROUP BY P_ID
) AS first_login ON l.P_ID = first_login.P_ID AND l.StartDate = first_login.min_start_time;

-- 11a
SELECT P_ID, CAST(StartDate AS date) AS play_date, 
       SUM(kill_count) OVER (PARTITION BY P_ID ORDER BY CAST(StartDate AS date)) AS total_kill_count
FROM level_details2
ORDER BY P_ID, CAST(StartDate AS date);

-- 11b

SELECT ld.P_ID, CAST(ld.StartDate AS date) AS play_date, 
       SUM(ld.kill_count) AS total_kill_count
FROM level_details2 ld
WHERE CAST(ld.StartDate AS date) <= (
    SELECT MAX(CAST(ld_inner.StartDate AS date))
    FROM level_details2 ld_inner
    WHERE ld_inner.P_ID = ld.P_ID
)
GROUP BY ld.P_ID, CAST(ld.StartDate AS date)
ORDER BY ld.P_ID, CAST(ld.StartDate AS date);

-- 12
SELECT  P_ID, StartDate, stages_crossed,
       SUM(stages_crossed) OVER (ORDER BY StartDate) AS cumulative_stages_crossed
FROM level_details2
ORDER BY StartDate;

-- 13 
WITH RankedStages AS (
    SELECT P_ID, StartDate, stages_crossed,
           ROW_NUMBER() OVER (PARTITION BY P_ID ORDER BY StartDate DESC) AS rn
    FROM level_details2
)

SELECT P_ID, StartDate, stages_crossed,
       SUM(Stages_crossed) OVER (PARTITION BY P_ID ORDER BY StartDate ASC ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS cumulative_stages_crossed
FROM RankedStages
WHERE rn > 1
ORDER BY P_ID, StartDate;

-- 14
WITH RankedScores AS (
    SELECT P_ID, Dev_ID, SUM(score) AS total_score,
           ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY SUM(score) DESC) AS rn
    FROM level_details2
    GROUP BY P_ID, Dev_ID
)

SELECT P_ID, Dev_ID, total_score
FROM RankedScores
WHERE rn <= 3
ORDER BY Dev_ID, total_score DESC;


-- 15 Q15) Find players who scored more than 50% of the avg score scored by sum of 
-- scores for each player_id

WITH PlayerAvgScores AS (
    SELECT P_ID, AVG(score) AS avg_score
    FROM level_details2
    GROUP BY P_ID
)

SELECT ld.P_ID, SUM(ld.score) AS total_score, pas.avg_score
FROM level_details2 ld
JOIN PlayerAvgScores pas ON ld.P_ID = pas.P_ID
GROUP BY ld.P_ID, pas.avg_score
HAVING SUM(ld.score) > 0.5 * pas.avg_score
ORDER BY ld.P_ID;


-- 16



-- 17 CREATE FUNCTION GetTotalScoreForPlayer

