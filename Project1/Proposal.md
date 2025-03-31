# 📌Proposal

## 1. Dataset
### 1.1 Description 
**"International Mathematical Olympiad (IMO) Data** is a publicly available dataset recored the World Championship Mathematics Competition for High School students from 1954 to 2024. The IMO is held annually in a different country and is taken part in over 100 countries from 5 continents. The competition consists of 6 problems and is held over two consecutive days with 3 problems each.

There are three key data files:
- `country_results_df.csv`: Aggregated country-level performance data, including team size and medal counts.
- `individual_results_df.csv`: Individual contestant performance and awards.
- `timeline_df.csv`: Historical timeline of IMO events, including host countries and participant demographics.

#### 1.1.1 The country results `country_results_df.csv`
- `year` (integer): Year of IMO
- `country` (character): Participating country
- `team_size_all` (integer): Participating contestants
- `team_size_male` (integer): Male contestants
- `team_size_female` (integer): Female contestants
- `p1` - `p7` (integer): Score on problem 1 - 7
- `awards_gold` (integer): Number of gold medals
- `awards_silver` (integer): Number of silver medals
- `awards_bronze` (integer): Number of bronze medals
- `awards_honorable_mentions` (integer): Number of honorable mentions
- `leader` (character): Leader of country team
- `deputy_leader` (character): Deputy leader of country team

#### 1.1.2 The individual results `individual_results_df.csv`
- `year` (integer): Year of IMO
- `contestant` (character): Participant's name
- `country` (character): Participant's country
- `p1` - `p6` (integer): Score on problem 1 - 6
- `total` (integer): Total score on all problems
- `individual_rank` (integer): Individual rank
- `award` (character): Award won

#### 1.1.3 The timeline and hosted countries `timeline_df.csv`
- `edition` (integer): Edition of International Mathematical Olympiad (IMO)
- `year` (integer): Year of IMO
- `country` (character): Host country
- `city` (character): Host city
- `countries` (integer): Number of participating countries
- `all_contestant` (integer): Number of participating contestants
- `male_contestant` (integer): Number of participating male contestants
- `female_contestant` (integer): Number of participating female contestants
- `start_date` (Date): Start date of IMO
- `end_date` (Date): End date of IMO

### 1.2 Reason
We're interested in finding new insights about how both internal and the external factors can influence the performance result, 
which is IMO score/ranking in this context. We believe that there might have some interesting relationships that have been 
unexplored yet, and we want to apply different visualization technique to deliver our exploration. 

---

## 2. Proposed Questions
### RQ 1. How variations of the aggregated country-level metadata influence country's performance and its shiftness over time?
- Variables involved:
  - `year`, `country`, `team_size_female`, `team_size_all`, `awards_gold`, `awards_silver`, `awards_bronze`

- Plan to analyze:
  - Handle missing values:
    - If `team_size_female` is missing, it will be inferred as `team_size_female = team_size_all - team_size_male`.
  - Aggregation: 
    - Compute  the **country performance** using a weighted sum of awards: `country_performance = 3 * awards_gold + 2 * awards_silver + awards_bronze`. 
  - Data Visualiztion: 
    - Female Participation Over Time: **A line chart** displaying the number of female participants (y-axis) across years (x-axis).
    - Country Performance Trends: **An interactive bar chart** showing performance scores over time, allowing users to select specific countries.
  - Insight: 
    - Examine the trends in female participation.
    - Identify countries with significant shifts in performance over time.
    - Analyze whether increased female participation correlates with higher performance.

### Q2. How do external environmental factors, such as on-site weather conditions would influence country & individual performance outcomes, and do these effects vary across participants from different geographical regions?"
- Variables involved:
  - `edition`, `year`, `country`, `city`, `All Contestants`, `Female Contestant`, `Male Contestants`, `Start Date`, `End Date`

- External dataset:
  - We will use the [OpenMetéo Weather API](https://open-meteo.com/), to obtain the historical weather data based on the location of city. We denote this dataset as ED_weather.
  - (2) We will use the data from [simplemaps.com](https://simplemaps.com) to obtain the location (latitude and longtitude) of the given city. We denote this dataset as ED_location.

- Plan to analyze:
  - Handling external dataset: We first use the ED_location dataset to get the locations, then maps each city in the IMO dataset. Then we use API calls to get weather dataset for each given city.

  - Preprocessing
    - Data Cleaning: Ensure that the temperature data is complete, with no missing values. If there are missing values, apply interpolation or fill them using the average temperature of the respective day or nearby days. Adjust temperature readings for differences in measurement units if necessary Merging Data: Merge the weather data with the contest dataset (i.e., edition, year, country, and number of contestants).

    - Participant Grouping: Group participants based on their home country (to evaluate if participants from warmer or colder regions perform differently when the contest is held in a specific climate).

    - Aggregation: Aggregate the temperature data to calculate the average daily temperature for each day in the contest period (across all days from start date to end date). Calculate the average temperature across all participating countries for the days of the contest. Compare the temperatures between the host city and the contestants' home countries to identify potential influences of local weather.

  - Visualization

    - Plot the daily average temperatures for both the host city and each participant’s home country during the contest period. This will give a visual sense of how weather conditions evolved throughout the contest.

    - Create heatmaps or scatter plots to compare the temperatures of the host city against each participating country. This visualization can reveal any correlation between the temperature difference and participant performance.

    - Visualize the relationship between the performance of each country and the temperature at the time of the contest. This can be done using scatter plots or box plots to see if there’s any significant pattern.

    - Create bar charts that break down performance based on geographical regions, comparing countries with extreme temperature conditions to those with moderate climates.


---
## Team Members:
- Pham Quoc Cuong
- Phan Minh Tri