# **📌Proposal **

## 1. Dataset
### 1.1 Introduction 
We use **"International Mathematical Olympiad (IMO) Data** - a publicly available dataset from [tidytuesday](https://github.com/rfordatascience/tidytuesday) to conduct analysis. 

- Published: 2024-09-24
- Github description: [link](https://github.com/rfordatascience/tidytuesday/blob/main/data/2024/2024-09-24/readme.md)

### 1.2 Reason
We're interested in finding new insights about how both internal and the external factors can influence the performance result, 
which is IMO score/ranking in this context. We believe that there might have some interesting relationships that have been 
unexplored yet, and we want to apply different visualization technique to deliver our exploration. 


### 1.3 Description 
The IMO is the World Championship Mathematics Competition for High School students and is held annually in a different country. 
The competition consists of 6 problems and is held over two consecutive days with 3 problems each.

At a glance, there are  three key data files:
- `country_results_df.csv`: Aggregated country-level performance data, including team size and medal counts.
- `individual_results_df.csv`: Individual contestant performance and awards.
- `timeline_df.csv`: Historical timeline of IMO events, including host countries and participant demographics.





## 2. Proposed Questions
### RQ 1. How variations of the aggregated country-level metadata influence country's performance and its shiftness over time?
- Analysis Plan: we aim to use different internal variablese, e.g., team size, proportion of 1st-time participants & returned veterans, 
gender distribution, etc. to explore any significant correlation to the performance result. 


### Q2. How do external environmental factors, such as on-site weather conditions would influence country & individual performance outcomes, and do these effects vary across participants from different geographical regions?"
- Analysis Plan: we aim to use external weather dataset (up-to-date, crawled by ourselves), 
extracting date-specific-location-specific temperature/humidity to explore the relationship 
between 





