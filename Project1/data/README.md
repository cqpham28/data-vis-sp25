## International Mathematical Olympiad (IMO) Data
### Description 
**"International Mathematical Olympiad (IMO) Data** is a publicly available dataset recored the World Championship Mathematics Competition for High School students from 1954 to 2024. The IMO is held annually in a different country and is taken part in over 100 countries from 5 continents. The competition consists of 6 problems and is held over two consecutive days with 3 problems each.

The dataset was collected by [Havisha Khurana](https://github.com/havishak) and published on [tidytuesday](https://github.com/rfordatascience/tidytuesday/blob/main/data/2024/2024-09-24/readme.md).

There are three key data files:
- `country_results_df.csv`: Aggregated country-level performance data, including team size and medal counts.
- `individual_results_df.csv`: Individual contestant performance and awards.
- `timeline_df.csv`: Historical timeline of IMO events, including host countries and participant demographics.

#### The country results `country_results_df.csv`
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

#### The individual results `individual_results_df.csv`
- `year` (integer): Year of IMO
- `contestant` (character): Participant's name
- `country` (character): Participant's country
- `p1` - `p6` (integer): Score on problem 1 - 6
- `total` (integer): Total score on all problems
- `individual_rank` (integer): Individual rank
- `award` (character): Award won

#### The timeline and hosted countries `timeline_df.csv`
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