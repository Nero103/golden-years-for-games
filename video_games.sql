-- PostgreSQL Data Analysis - Golden Years of Video Games

/* Preprocessing data */

-- Add a primary key to the game table for joining later
ALTER TABLE game_sales_data
ADD COLUMN Id SERIAL PRIMARY KEY;

-- Add a primary key to the critic/user table for joining later
ALTER TABLE critic_user_data
ADD COLUMN Id SERIAL PRIMARY KEY;

/* Data analysis */

-- 1. What are the top ten best-selling games?
SELECT *
FROM game_sales_data
ORDER BY "Total_Shipped" DESC
LIMIT 10;

-- 2. What are the bottom ten selling games?
SELECT *
FROM game_sales_data
ORDER BY "Total_Shipped" ASC
LIMIT 10;

/* So, the best selling games were between 1985 and 2017
The least selling games were between 2006 and 2018 */

-- 3. What is the range of scores?
SELECT *
FROM critic_user_data
ORDER BY "Critic_Score" DESC
LIMIT 10;

SELECT *
FROM critic_user_data
ORDER BY "Critic_Score" ASC
LIMIT 10;

-- 4. Based on the last result-set, what is the number of missing review scores for games?
SELECT COUNT(*) AS null_count
FROM game_sales_data AS g
INNER JOIN critic_user_data AS r
ON g."Id" = r."Id"
WHERE r."Critic_Score" IS NULL AND r."User_Score" IS NULL;

-- 5. How many reviews are not missing?
SELECT COUNT(*) AS not_null_count
FROM game_sales_data AS g
INNER JOIN critic_user_data AS r
ON g."Id" = r."Id"
WHERE r."Critic_Score" IS NOT NULL AND r."User_Score" IS NOT NULL;

-- 6. What is the percentage of missing data in the dataset?
SELECT (SELECT COUNT(*) AS null_count
      FROM game_sales_data AS g
      INNER JOIN critic_user_data AS r
      ON g."Id" = r."Id"
      WHERE r."Critic_Score" IS NULL AND r."User_Score" IS NULL)::FLOAT/ COUNT(*)::FLOAT AS null_percentage
FROM game_sales_data AS g
      INNER JOIN critic_user_data AS r
      ON g."Id" = r."Id";

/* From the the results, the portion of missing data is approximately half. That's a lot!
Upon further exploration using excel, the data does not have a normal ditribution.
So, the missing data will be handled with a different strategy */


-- 7. Impute the missing values in critic_scores with the median.
UPDATE critic_user_data
SET "Critic_Score" = (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Critic_Score") FROM critic_user_data)
WHERE "Critic_Score" IS NULL;

-- 8. Impute the missing values in user_scores with the median.
UPDATE critic_user_data
SET "User_Score" = (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "User_Score") FROM critic_user_data)
WHERE "User_Score" IS NULL;

-- 9. Now, check the data for missing values
SELECT COUNT(*) AS null_count
FROM game_sales_data AS g
INNER JOIN critic_user_data AS r
ON g."Id" = r."Id"
WHERE r."Critic_Score" IS NULL AND r."User_Score" IS NULL;

/* With the missing values handled, the reviews from critics can be explored */

-- 10. What are the top ten years that critics loved a game?
CREATE OR REPLACE VIEW critic_favorite_games_year AS
SELECT g."Year",
        AVG(r."Critic_Score") AS avg_critic_score
FROM game_sales_data AS g
INNER JOIN critic_user_data AS r
ON g."Id" = r."Id"
GROUP BY g."Year"
ORDER BY avg_critic_score DESC
LIMIT 10;

/* Critics seem to love games from 1984 through 2020. The year 1989 seems well rounded in review score, 
which seems strange for an average. The result might be from 1989 not having a lot of video games in the dataset.
Let's see if 1989 had a lot of games that year */

-- 11. What are the top ten number of games?
CREATE OR REPLACE VIEW critic_favorite_games_year_more_than_twenty_games AS 
SELECT g."Year",
        AVG(r."Critic_Score") AS avg_critic_score,
        COUNT(*) AS num_games
FROM game_sales_data AS g
INNER JOIN critic_user_data AS r
ON g."Id" = r."Id"
GROUP BY g."Year"
HAVING COUNT(*) > 20
ORDER BY avg_critic_score DESC
LIMIT 10;


/* The new result-set of critic scores looks more accurate. Having the number of games provides evidence that the new list
reflects years that had a decent number of well-reviewed video games. However, now a new question emerged.
Which years changed between the years? Let's identify the changed years in case there needs to be a deeper look at the data. */

-- 12. Using the previous results from critic's favorite games and more than twenty games,
-- which years were dropped from the critic's review list?
SELECT c1."Year", 
        avg_critic_score
FROM critic_favorite_games_year AS c1
EXCEPT
SELECT c2."Year",
        avg_critic_score
FROM critic_favorite_games_year_more_than_twenty_games AS c2
ORDER BY avg_critic_score DESC;

/* Base on the result-set from question 11, it seems the 1990s and 2010s could be considered the golden age of video games,
at least based on critic reviews. Let's see how the opinion of users lines-up to the critic's opinion. */

-- What are the users favorite games?
CREATE OR REPLACE VIEW user_favorite_games_year_more_than_twenty_games AS
SELECT g."Year",
        AVG(r."User_Score") AS avg_user_score,
        COUNT(*) AS num_games
FROM game_sales_data AS g
INNER JOIN critic_user_data AS r
ON g."Id" = r."Id"
GROUP BY g."Year"
HAVING COUNT(*) > 20
ORDER BY avg_user_score DESC
LIMIT 10;

-- What are the years of video games both critics and users favor?
SELECT c."Year"
FROM critic_favorite_games_year_more_than_twenty_games AS c
INTERSECT
SELECT u."Year"
FROM user_favorite_games_year_more_than_twenty_games AS u;

/* Now that the favorite years for video games from critics and users is known,
the amount of games sold can be explored */

-- What are the total sales in the 'best' video game years?
SELECT g."Year",
        SUM("Total_Shipped") AS total_games_sold
FROM game_sales_data AS g
      LEFT JOIN critic_user_data AS r
      ON g."Id" = r."Id"
WHERE g."Year" IN (SELECT c."Year"
                FROM critic_favorite_games_year_more_than_twenty_games AS c
                INTERSECT
                SELECT u."Year"
                FROM user_favorite_games_year_more_than_twenty_games AS u)
GROUP BY g."Year"
ORDER BY total_games_sold DESC;


/* Data project inspired from DataCamp. Dataset retrieved from Kaggle, dataset: Video Game Sales Data */