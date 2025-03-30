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
- `p1` (integer): Score on problem 1
- `p2` (integer): Score on problem 2
- `p3` (integer): Score on problem 3
- `p4` (integer): Score on problem 4
- `p5` (integer): Score on problem 5
- `p6` (integer): Score on problem 6
- `p7` (integer): Score on problem 7
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
- `p1` (integer): Score on problem 1
- `p2` (integer): Score on problem 2
- `p3` (integer): Score on problem 3
- `p4` (integer): Score on problem 4
- `p5` (integer): Score on problem 5
- `p6` (integer): Score on problem 6
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


## 2. Proposed Questions
### RQ 1. How variations of the aggregated country-level metadata influence country's performance and its shiftness over time?
- Variables involved:
  - `year`, `country`, `team_size_female`, `team_size_all`, `awards_gold`, `awards_silver`, `awards_bronze`

- Plan:
  - We aim to use different internal variablese, e.g., team size, proportion of 1st-time participants & returned veterans, gender distribution, etc. to explore any significant correlation to the performance result. 


### Q2. How do external environmental factors, such as on-site weather conditions would influence country & individual performance outcomes, and do these effects vary across participants from different geographical regions?"
- Variables involved:
  - `edition`, `year`, `country`, `city`

- External dataset:
  - We will create a temperature data of hosted countries and participant's country by using Open source [Weather API](https://open-meteo.com/).

- Plan:
  -  we aim to use external weather dataset (up-to-date, crawled by ourselves), 
extracting date-specific-location-specific temperature/humidity to explore the relationship 
between 





