# Golden-years-for-games
This project explores video game sales data from 1977 to 2020 using PostgreSQL and Excel.

## Background
The data was collected from Kaggle and split into two tables. The first table covers game sales data. The second table covers critic and user reviews. Splitting the dataset was done to explore each table for missing data. This project was inspired by the capstone project from DataCamp's Data Analyst in SQL track. 

## Business Task
The goal of this project is to uncover which year(s) were the best for video games. Solving this problem could help game industries consider adopting strategies from game development during those years, whether it be gameplay value, technology features, or story design. Such information could drive revenue growth from game sales.

## Technical Tools
The tools used for this analysis were SQL (PostgreSQL) and Excel.

## Preprocessing the data
As mentioned the dataset was split into two tables to explore the data, checking for consistency, accuracy, and comprehension. First was the check for missing values, which made up almost half the dataset. Since approximately 49% of the data was missing, it seemed harmful to remove all that data. I used Excel to see the distribution of the reviews, to give me an idea of how to impute data into the missing values. The data showed a non-normal distribution, specifically a skewed left distribution. This finding suggested I use the median to fill in the missing values. After the data was imputed, I checked the game sales table, which had no missing values.

Next, I planned to join the tables during the analysis. Noticing that neither table had a key, I wanted to avoid duplicating the records, so a new column was added with incremented ID values to both tables. These columns were assigned primary keys.

## Data Analysis
Upon analysis, I explored several aspects of the data such as the top ten years of video games favored by critics, the number of games released that year, and users' favorite games. To get an accurate view of critic's opinions on their favored games, I created a View of the critics' favorite games by review and a View that put the reviews against the number of games released. I compared the Views to see which years were excluded. Then I compared the views of critics' favorite games by review and number released with the users' favorite games by review and number released. This comparison searched for intercepting years, which produced a result-set of four years of games favored by both critics and users - 1992, 1993, 1991, and 1990.

## Conclusion
From the analysis, it is presumed that the early nineties were the 'golden age of games' according to critics and user opinions. This result could be from video games becoming more popular due to emerging technologies around that time. Video games began a transition from 2D to 3D graphics and genres such as first-person shooters, strategy, and massively multiplayer online games were introduced. Many innovative elements were also introduced in the survival horror genre.

## Recommendation
Based on this conclusion, we can presume technological innovation may have influenced the favored reception from critics and users. Although, this presumption is tentative and would need more data to support it. Perhaps surveys could be distributed to gamers from the nineties to the current time to determine which innovative features gamers liked most in video games. Then, each participant could be grouped by their birth year and have their responses analyzed for similarities and differences. Exploring such data could lead to an increase in future or current games sold.

## Limitations
There was no response data from the critic and users review table to understand why critics and users gave the score they did. Also, since the missing data was imputed with the median, approximately half the review scores are not 100% accurate to what critics and users may have given during that year.
