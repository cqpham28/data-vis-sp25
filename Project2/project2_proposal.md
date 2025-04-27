# Proposal: Interactive Dashboard for Macroeconomic Indicators

Group 05:
- Vu Tuyet Vy - V202401789
- Pham Quoc Cuong - V202401658

## High-level Goal
Our project aims to build an interactive Shiny dashboard to monitor and visualize key macroeconomic indicators across selected global economies, providing comparative insights, dynamic analysis and real-time exploration for whoever interests.

## Project Introduction
**Background:** Economic monitoring is essential for policy-making, investment decisions, and academic research to make informed decisions. Macroeconomic trends such as GDP growth, inflation, trade balances, and financial indicators reflect the trajectory of an economy. Large volumes of data often exists across fragmented platforms such as the World Bank, IMF, and OECD databases. Among those, the World Bank provides one of the most comprehensive and reliable open datasets for such macroeconomic indicators, covering a wide range of countries, years, and development categories.

**Problem:** In many cases, users face several problems when they want to explore trends or conduct comparative analysis, since they have to download multiple datasets manually and perform time-consuming analysis. This cause technical challenges especially for those who are not familiar with data wrangling or visualization tools. 

For instance, understanding macroeconomic trends across various countries is challenging due to the following constraints:
- Data Complexity: require knowledge of specific indicator codes, and metadata.
- Fragmented Access: require download and filter large datasets manually.
- Static Reporting: not allow for dynamic exploration & filtering.
- Limited Comparative: difficult to compare cross-countries indicators interactively. 


**Motivation**: Our motivation is to simplify this task by creating an intuitive, interactive platform that consolidates critical economic data from reliable sources such as the World Bank, and centralize the information into a single interactive dashboard.

**Objective**: To this end, the dashboard will feature interactive visualizations that allow users to:
- Fetch and Process Data directly from the World Bank’s up-to-date APIs
- Explore and compare economic and social conditions across countries
- Enable Custom Analyses, e.g., trade balances and terms of trade, financial and monetary indicators to understand currency strength and financial stability.

## Data and Indicators

The data utilized in this project is sourced from the World Bank, encompassing daily updates of high-frequency indicators reflecting global economic developments. The dataset covers advanced economies as well as emerging markets and developing economies, with data availability at annual frequency from the year 2000 to 2023 (and partial data for some countries extending to 2024).

The data covers diverse areas including consumer prices, exchange rates, foreign reserves, GDP, industrial production, merchandise trade, retail sales, stock markets, terms of trade, unemployment, and population data. Given that data for different indicators are stored in separate Excel/CSV files and not all countries provide complete data for every indicator, our team has carefully reviewed and selected a set of representative countries. We processed and integrated these separate datasets into a unified, comprehensive data model suitable for interactive visualizations.

Specifically, the indicators selected for our analysis are:

**Economic & Social Indicators:**
- GDP growth (real and nominal, year-over-year)
- GDP per capita (calculated from GDP and population data)
- Inflation rates (Consumer Price Index, both headline CPI and core CPI)
- Retail sales volume (consumer spending index)
- Unemployment rate

**Trade Indicators:**
- Merchandise exports and imports (current USD, seasonally adjusted)
- Trade balance (exports minus imports)
- Terms of trade

**Financial & Monetary Indicators:**
- Official exchange rates (local currency units per USD)
- Nominal Effective Exchange Rate (NEER)
- Real Effective Exchange Rate (REER)
- Total foreign reserves
- Months of import coverage provided by reserves

## Dashboard Structure and Visualization

The final product will be an interactive Shiny app, structured clearly into three distinct topic tabs, each addressing specific analytical areas:

### 1. Economic & Social Overview Tab
- **Indicators:** GDP growth, GDP per capita, inflation rates, retail sales volume, unemployment rate.
- **Visualizations:**
  - KPI cards for quick data summary.
  - Multi-series line charts comparing multiple indicators simultaneously across countries and time.
  - Bar ranking charts for current indicator rankings.
  - Scatter plots showing correlations (e.g., GDP per capita vs. GDP growth or unemployment rate).

### 2. Trade Balance Tab
- **Indicators:** Merchandise exports/imports, trade balance, terms of trade.
- **Visualizations:**
  - Stacked bar charts illustrating quarterly export and import trends.
  - Line charts tracking trade balance changes over time.
  - Bubble charts showing relationships between trade balances, terms of trade, and economic size.

### 3. Financial & Monetary Indicators Tab
- **Indicators:** Exchange rates, NEER, REER, foreign reserves, import cover.
- **Visualizations:**
  - Dual-axis line charts comparing currency exchange rates (LCU/USD) alongside effective exchange rates (NEER, REER).
  - Grouped column charts comparing reserve levels and import coverage.
  - KPI cards highlighting recent financial stability metrics.

### Expected Outcome
- Interactive, robust Shiny dashboard with comprehensive visualizations.
- Well-documented and reproducible R code on GitHub.
- Detailed analytical project report.

## Weekly Project Timeline and Roles

**Week 1 (21/04 - 27/04):**
- Brainstorm ideas, finalize indicators, submit the project proposal, and set up GitHub repository.
- Vy: Lead proposal writing and ideation.
- Cuong: Repository setup, data sourcing.

**Week 2 (28/04 - 04/05):**
- Conduct peer reviews, data model development, dataset cleaning.
- Vy: Data processing and initial development of the Economic & Social Overview tab.
- Cuong: Address feedback, assist coding.

**Week 3 (05/05 - 15/05):**
- Complete the Economic & Social Overview tab; start and progress Trade Balance tab.
- Finalize revised proposal based on feedback.
- Vy: Lead coding and project monitoring.
- Cuong: Develop Trade Balance visualizations, support integration.

**Week 4 (16/05 - 23/05):**
- Complete Trade Balance tab, begin Financial & Monetary Indicators tab.
- Conduct initial dashboard testing.
- Vy: Finalize Trade Balance tab and initiate Financial tab.
- Cuong: Visualizations and user interface enhancement.

**Week 5 (24/05 - 30/05):**
- Finish Financial & Monetary Indicators tab, extensive testing, debugging, adjustments.
- Prepare final report and presentation.
- Vy: Report writing, project reviewr, prepare for presentation.
- Cuong: Final code refinement, testing, assist report writing, prepare for presentation.
