# app.R

#-----------------------------------------------------------
# Global Macro Dashboard: Shiny App for 8 Countries
#
# Indicators:
#   - CPI inflation (YoY %)
#   - GDP real (constant 2010 USD) and GDP growth (% YoY)
#   - Unemployment Rate (%)
#   - Industrial Production (constant 2010 USD)
#   - Exports & Imports (current USD)
#   - Trade Balance = Exports − Imports (aggregated over selected years)
#   - FX Rate (LCU per USD)
#
# Countries:
#   United States, China, Germany, Japan, India, Brazil, South Africa, Viet Nam
#
# Data are read from each file’s sheet “annual” (yearly data).
#
# Color scheme (hex) for each country:
#   United States → #80CBC4
#   China         → #B4EBE6
#   Germany       → #FFAAAA  ← ĐÃ CẬP NHẬT
#   Japan         → #FFB433
#   India         → #001A6E
#   Brazil        → #074799
#   South Africa  → #009990
#   Viet Nam      → #E1FFBB
#
# In this version:
#   • Tab 1 (Economic & Social): multi‐series line, ranking bar, scatter.
#   • Tab 2 (Trade Balance):
#       – If “Exports” or “Imports” chosen → line chart over selected years.
#       – If “Trade Balance” chosen → waterfall chart of TOTAL Exports & Imports
#         aggregated over the selected year range, per country (with Net).
#       – Plus a box listing selected countries.
#       – Plus subplots “Trade Balance Over Time” & “Bubble: TB vs GDP”.
#   • Tab 3 (Financial & Monetary):
#       – KPI cards for FX Rate (and placeholders for NEER/REER/etc).
#       – Line chart of FX Rate over selected years.
#       – KPI cards are embedded inside the “Options” box.
#
# This file assumes all .xlsx files are placed in the same folder as app.R.
#-----------------------------------------------------------

library(shiny)
library(shinydashboard)
library(tidyverse)
library(readxl)
library(plotly)

#-----------------------------------------------------------
# 1. HELPER FUNCTION TO READ “annual” SHEETS & HANDLE MISSING COLUMNS
#-----------------------------------------------------------

read_year_long <- function(path, value_name) {
  # 1. Đọc sheet “annual”
  df <- read_excel(path, sheet = "annual")
  # 2. Rename first column to “Year” if needed
  if (!("Year" %in% names(df))) {
    df <- df %>% rename(Year = 1)
  }
  # 3. Danh sách 8 quốc gia
  countries <- c(
    "United States", "China", "Germany", "Japan",
    "India", "Brazil", "South Africa", "Viet Nam"
  )
  # 4. Keep Year + any existing country columns
  df_sel <- df %>% select(Year, any_of(countries))
  # 5. Coerce to numeric
  df_sel <- df_sel %>% mutate(across(any_of(countries), as.numeric))
  # 6. Pivot to long
  df_long <- df_sel %>%
    pivot_longer(
      cols      = any_of(countries),
      names_to  = "Country",
      values_to = value_name
    )
  return(df_long)
}

#-----------------------------------------------------------
# 2. READ & PROCESS ALL DATA
#-----------------------------------------------------------

path_cpi_index    <- "CPI Price, nominal, seas. adj..xlsx"
path_gdp_real     <- "GDP at market prices, constant 2010 US$, millions, seas. adj..xlsx"
path_unemp        <- "Unemployment Rate, seas. adj..xlsx"
path_ip_real      <- "Industrial Production, constant 2010 US$, seas. adj..xlsx"
path_exports      <- "Exports Merchandise, Customs, current US$, millions, seas. adj..xlsx"
path_imports      <- "Imports Merchandise, Customs, current US$, millions, seas. adj..xlsx"
path_fx           <- "Official exchange rate, LCU per USD, period average.xlsx"

# CPI → CPI inflation (% YoY)
df_cpi_index <- read_year_long(path_cpi_index, "CPI_index")
df_cpi <- df_cpi_index %>%
  arrange(Country, Year) %>%
  group_by(Country) %>%
  mutate(CPI_inflation = (CPI_index - lag(CPI_index)) / lag(CPI_index) * 100) %>%
  ungroup() %>%
  select(Country, Year, CPI_inflation)

# GDP real → GDP growth (% YoY)
df_gdp_real <- read_year_long(path_gdp_real, "GDP_real")
df_gdp <- df_gdp_real %>%
  arrange(Country, Year) %>%
  group_by(Country) %>%
  mutate(GDP_growth = (GDP_real - lag(GDP_real)) / lag(GDP_real) * 100) %>%
  ungroup()

# Unemployment Rate (%)
df_unemp <- read_year_long(path_unemp, "Unemp_rate")

# Industrial Production (constant 2010 USD)
df_ip <- read_year_long(path_ip_real, "IP_real")

# Exports (current USD)
df_exp <- read_year_long(path_exports, "Exports")

# Imports (current USD)
df_imp <- read_year_long(path_imports, "Imports")

# Trade Balance = Exports − Imports (we’ll aggregate later)
df_tb <- df_exp %>%
  left_join(df_imp, by = c("Country", "Year")) %>%
  mutate(Trade_Balance = Exports - Imports) %>%
  select(Country, Year, Trade_Balance)

# FX Rate (LCU per USD)
df_fx <- read_year_long(path_fx, "FX_rate")

# Merge all into df_full
df_full <- df_cpi %>%
  left_join(df_gdp,   by = c("Country", "Year")) %>%
  left_join(df_unemp, by = c("Country", "Year")) %>%
  left_join(df_ip,    by = c("Country", "Year")) %>%
  left_join(df_exp,   by = c("Country", "Year")) %>%
  left_join(df_imp,   by = c("Country", "Year")) %>%
  left_join(df_tb,    by = c("Country", "Year")) %>%
  left_join(df_fx,    by = c("Country", "Year"))

df_full <- df_full %>%
  filter(Year >= 2000, Year <= 2023) %>%
  arrange(Country, Year)

df_full$Country <- factor(df_full$Country, levels = c(
  "United States", "China", "Germany", "Japan",
  "India", "Brazil", "South Africa", "Viet Nam"
))

country_list <- levels(df_full$Country)
year_list    <- sort(unique(df_full$Year))

#-----------------------------------------------------------
# 2.14. DEFINE COLOR SCHEME FOR COUNTRIES
#-----------------------------------------------------------
country_colors <- c(
  "United States" = "#80CBC4",
  "China"         = "#B4EBE6",
  "Germany"       = "#FFAAAA",  # ← Đã đổi thành #FFAAAA
  "Japan"         = "#FFB433",
  "India"         = "#001A6E",
  "Brazil"        = "#074799",
  "South Africa"  = "#009990",
  "Viet Nam"      = "#E1FFBB"
)

#-----------------------------------------------------------
# 3. SHINY UI
#-----------------------------------------------------------

ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(title = "Global Macro Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Economic & Social Overview", tabName = "econ_social", icon = icon("chart-line")),
      menuItem("Trade Balance",            tabName = "trade",        icon = icon("balance-scale")),
      menuItem("Financial & Monetary",     tabName = "fin_monet",    icon = icon("dollar-sign"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      #======================================
      # Tab 1: Economic & Social Overview
      #======================================
      tabItem(
        tabName = "econ_social",
        
        # — Options —
        fluidRow(
          box(
            title = "Options",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            fluidRow(
              column(
                width = 4,
                selectInput(
                  inputId = "es_countries",
                  label   = "Choose Countries:",
                  choices = country_list,
                  selected = country_list,
                  multiple = TRUE
                )
              ),
              column(
                width = 4,
                sliderInput(
                  inputId = "es_year_range",
                  label   = "Select Year Range:",
                  min     = min(year_list),
                  max     = max(year_list),
                  value   = c(min(year_list), max(year_list)),
                  sep     = ""
                )
              ),
              column(
                width = 4,
                selectInput(
                  inputId = "es_indicator",
                  label   = "Indicator:",
                  choices = c(
                    "GDP Growth (%)"          = "GDP_growth",
                    "Inflation (%)"           = "CPI_inflation",
                    "Unemployment (%)"        = "Unemp_rate",
                    "Industrial Prod. (M USD)" = "IP_real"
                  ),
                  selected = "GDP_growth"
                )
              )
            )
          )
        ),
        
        # — KPI Boxes —
        fluidRow(
          valueBoxOutput("kpi_gdp_growth",    width = 3),
          valueBoxOutput("kpi_inflation",     width = 3),
          valueBoxOutput("kpi_unemployment",  width = 3),
          valueBoxOutput("kpi_industrial",    width = 3)
        ),
        
        # — Trend Comparison —
        fluidRow(
          box(
            title = "Trend Comparison",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("line_es_trend", height = "400px")
          )
        ),
        
        # — Ranking & Scatter —
        fluidRow(
          box(
            title = "Ranking in Most Recent Year",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("bar_es_ranking", height = "350px")
          ),
          box(
            title = "Correlation Scatter Plot",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            fluidRow(
              column(
                width = 6,
                selectInput(
                  inputId = "scatter_x",
                  label   = "X-axis:",
                  choices = c(
                    "GDP Growth (%)"          = "GDP_growth",
                    "Inflation (%)"           = "CPI_inflation",
                    "Unemployment (%)"        = "Unemp_rate",
                    "Industrial Prod. (M USD)" = "IP_real"
                  ),
                  selected = "GDP_growth"
                )
              ),
              column(
                width = 6,
                selectInput(
                  inputId = "scatter_y",
                  label   = "Y-axis:",
                  choices = c(
                    "GDP Growth (%)"          = "GDP_growth",
                    "Inflation (%)"           = "CPI_inflation",
                    "Unemployment (%)"        = "Unemp_rate",
                    "Industrial Prod. (M USD)" = "IP_real"
                  ),
                  selected = "CPI_inflation"
                )
              )
            ),
            plotlyOutput("scatter_es_corr", height = "350px")
          )
        )
      ), # end econ_social
      
      
      #======================================
      # Tab 2: Trade Balance
      #======================================
      tabItem(
        tabName = "trade",
        
        # — Options —
        fluidRow(
          box(
            title = "Options",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            fluidRow(
              column(
                width = 4,
                selectInput(
                  inputId = "trade_countries",
                  label   = "Choose Countries:",
                  choices = country_list,
                  selected = country_list,
                  multiple = TRUE
                )
              ),
              column(
                width = 4,
                sliderInput(
                  inputId = "trade_year_range",
                  label   = "Select Year Range:",
                  min     = min(year_list),
                  max     = max(year_list),
                  value   = c(min(year_list), max(year_list)),
                  sep     = ""
                )
              ),
              column(
                width = 4,
                selectInput(
                  inputId = "trade_indicator",
                  label   = "Indicator:",
                  choices = c(
                    "Exports"       = "Exports",
                    "Imports"       = "Imports",
                    "Trade Balance" = "Trade_Balance"
                  ),
                  selected = "Trade_Balance"
                )
              )
            )
          )
        ),
        
        # — Selected Countries —
        fluidRow(
          box(
            title = "Selected Countries",
            width = 12,
            status = "warning",
            solidHeader = TRUE,
            textOutput("selected_trade_countries")
          )
        ),
        
        # — Dynamic Chart: Exports/Imports line or Trade Balance waterfall —
        fluidRow(
          box(
            title = "Export–Import Overview",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("trade_dynamic_plot", height = "450px")
          )
        ),
        
        # — Trade Balance Over Time & Bubble Chart —
        fluidRow(
          box(
            title = "Trade Balance Over Time",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("line_tb", height = "350px")
          ),
          box(
            title = "Bubble Chart: TB vs GDP (Size ~ GDP_real)",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("bubble_trade", height = "350px")
          )
        )
      ), # end trade
      
      
      #======================================
      # Tab 3: Financial & Monetary Indicators
      #======================================
      tabItem(
        tabName = "fin_monet",
        
        # — Options with embedded KPI cards —
        fluidRow(
          box(
            title = "Options",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            
            # 3 dropdown controls
            fluidRow(
              column(
                width = 4,
                selectInput(
                  inputId = "fm_countries",
                  label   = "Choose Countries:",
                  choices = country_list,
                  selected = country_list,
                  multiple = TRUE
                )
              ),
              column(
                width = 4,
                sliderInput(
                  inputId = "fm_year_range",
                  label   = "Select Year Range:",
                  min     = min(year_list),
                  max     = max(year_list),
                  value   = c(min(year_list), max(year_list)),
                  sep     = ""
                )
              ),
              column(
                width = 4,
                selectInput(
                  inputId = "fm_indicator",
                  label   = "Indicator:",
                  choices = c(
                    "FX Rate (LCU/USD)" = "FX_rate"
                    # (Thêm NEER/REER/Reserves nếu có dữ liệu)
                  ),
                  selected = "FX_rate"
                )
              )
            ),
            
            # 3 KPI boxes
            fluidRow(
              column(
                width = 4,
                valueBoxOutput("kpi_fx_rate", width = 12)
              ),
              column(
                width = 4,
                valueBoxOutput("kpi_dummy1", width = 12)
              ),
              column(
                width = 4,
                valueBoxOutput("kpi_dummy2", width = 12)
              )
            )
            
          )
        ),
        
        # — FX Rate Over Time (or other financial indicator) —
        fluidRow(
          box(
            title = "FX Rate Over Time",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("line_fx", height = "400px")
          )
        )
        
      ) # end fin_monet
      
    ) # end tabItems
  ) # end dashboardBody
) # end dashboardPage

#-----------------------------------------------------------
# 4. SHINY SERVER
#-----------------------------------------------------------

server <- function(input, output, session) {
  
  #======================================
  # Tab 1: Economic & Social Overview
  #======================================
  
  df_es <- reactive({
    req(input$es_countries, input$es_year_range)
    df_full %>%
      filter(
        Country %in% input$es_countries,
        Year >= input$es_year_range[1],
        Year <= input$es_year_range[2]
      )
  })
  
  output$kpi_gdp_growth <- renderValueBox({
    df1 <- df_es() %>%
      filter(Year == max(Year, na.rm = TRUE)) %>%
      summarise(val = mean(GDP_growth, na.rm = TRUE)) %>%
      pull(val)
    valueBox(
      subtitle = "Avg GDP Growth (%)",
      value    = ifelse(is.na(df1), "N/A", sprintf("%.2f%%", df1)),
      icon     = icon("chart-line"),
      color    = "teal"
    )
  })
  
  output$kpi_inflation <- renderValueBox({
    df1 <- df_es() %>%
      filter(Year == max(Year, na.rm = TRUE)) %>%
      summarise(val = mean(CPI_inflation, na.rm = TRUE)) %>%
      pull(val)
    valueBox(
      subtitle = "Avg Inflation (%)",
      value    = ifelse(is.na(df1), "N/A", sprintf("%.2f%%", df1)),
      icon     = icon("tachometer-alt"),
      color    = "aqua"
    )
  })
  
  output$kpi_unemployment <- renderValueBox({
    df1 <- df_es() %>%
      filter(Year == max(Year, na.rm = TRUE)) %>%
      summarise(val = mean(Unemp_rate, na.rm = TRUE)) %>%
      pull(val)
    valueBox(
      subtitle = "Avg Unemployment (%)",
      value    = ifelse(is.na(df1), "N/A", sprintf("%.2f%%", df1)),
      icon     = icon("users"),
      color    = "olive"
    )
  })
  
  output$kpi_industrial <- renderValueBox({
    df1 <- df_es() %>%
      filter(Year == max(Year, na.rm = TRUE)) %>%
      summarise(val = mean(IP_real, na.rm = TRUE)) %>%
      pull(val)
    valueBox(
      subtitle = "Avg Industrial Prod. (M USD)",
      value    = ifelse(is.na(df1), "N/A", scales::comma(df1)),
      icon     = icon("industry"),
      color    = "orange"
    )
  })
  
  output$line_es_trend <- renderPlotly({
    req(input$es_indicator)
    df_plot <- df_es() %>%
      mutate(Value = case_when(
        input$es_indicator == "GDP_growth"    ~ GDP_growth,
        input$es_indicator == "CPI_inflation" ~ CPI_inflation,
        input$es_indicator == "Unemp_rate"    ~ Unemp_rate,
        input$es_indicator == "IP_real"       ~ IP_real
      ))
    y_label <- case_when(
      input$es_indicator == "GDP_growth"    ~ "GDP Growth (%)",
      input$es_indicator == "CPI_inflation" ~ "Inflation (%)",
      input$es_indicator == "Unemp_rate"    ~ "Unemployment (%)",
      input$es_indicator == "IP_real"       ~ "Industrial Prod. (M USD)"
    )
    p <- ggplot(df_plot, aes(x = Year, y = Value, color = Country)) +
      geom_line(size = 1) +
      geom_point(size = 2) +
      scale_color_manual(values = country_colors) +
      labs(x = "Year", y = y_label, color = "Country") +
      theme_minimal()
    ggplotly(p) %>% layout(legend = list(orientation = "h", x = 0.2, y = -0.2))
  })
  
  output$bar_es_ranking <- renderPlotly({
    req(input$es_indicator)
    yr_max <- input$es_year_range[2]
    df_rank <- df_es() %>%
      filter(Year == yr_max) %>%
      mutate(Value = case_when(
        input$es_indicator == "GDP_growth"    ~ GDP_growth,
        input$es_indicator == "CPI_inflation" ~ CPI_inflation,
        input$es_indicator == "Unemp_rate"    ~ Unemp_rate,
        input$es_indicator == "IP_real"       ~ IP_real
      )) %>%
      arrange(desc(Value))
    y_label <- case_when(
      input$es_indicator == "GDP_growth"    ~ "GDP Growth (%)",
      input$es_indicator == "CPI_inflation" ~ "Inflation (%)",
      input$es_indicator == "Unemp_rate"    ~ "Unemployment (%)",
      input$es_indicator == "IP_real"       ~ "Industrial Prod. (M USD)"
    )
    p <- ggplot(df_rank, aes(x = reorder(Country, Value), y = Value, fill = Country)) +
      geom_col() +
      scale_fill_manual(values = country_colors) +
      coord_flip() +
      labs(x = "Country", y = y_label, title = paste("Ranking in", yr_max)) +
      theme_minimal() +
      theme(legend.position = "none")
    ggplotly(p)
  })
  
  output$scatter_es_corr <- renderPlotly({
    req(input$scatter_x, input$scatter_y)
    yr_max <- input$es_year_range[2]
    df_sc <- df_es() %>%
      filter(Year == yr_max) %>%
      mutate(
        X = case_when(
          input$scatter_x == "GDP_growth"    ~ GDP_growth,
          input$scatter_x == "CPI_inflation" ~ CPI_inflation,
          input$scatter_x == "Unemp_rate"    ~ Unemp_rate,
          input$scatter_x == "IP_real"       ~ IP_real
        ),
        Y = case_when(
          input$scatter_y == "GDP_growth"    ~ GDP_growth,
          input$scatter_y == "CPI_inflation" ~ CPI_inflation,
          input$scatter_y == "Unemp_rate"    ~ Unemp_rate,
          input$scatter_y == "IP_real"       ~ IP_real
        )
      )
    x_label <- case_when(
      input$scatter_x == "GDP_growth"    ~ "GDP Growth (%)",
      input$scatter_x == "CPI_inflation" ~ "Inflation (%)",
      input$scatter_x == "Unemp_rate"    ~ "Unemployment (%)",
      input$scatter_x == "IP_real"       ~ "Industrial Prod. (M USD)"
    )
    y_label <- case_when(
      input$scatter_y == "GDP_growth"    ~ "GDP Growth (%)",
      input$scatter_y == "CPI_inflation" ~ "Inflation (%)",
      input$scatter_y == "Unemp_rate"    ~ "Unemployment (%)",
      input$scatter_y == "IP_real"       ~ "Industrial Prod. (M USD)"
    )
    p <- ggplot(df_sc, aes(x = X, y = Y, color = Country, text = Country)) +
      geom_point(aes(size = abs(X * Y)), alpha = 0.7) +
      scale_color_manual(values = country_colors) +
      geom_text(aes(label = Country), vjust = -1, size = 3) +
      labs(x = x_label, y = y_label, title = paste("Correlation at", yr_max)) +
      theme_minimal() +
      theme(legend.position = "none")
    ggplotly(p, tooltip = c("text", "x", "y"))
  })
  
  
  #======================================
  # Tab 2: Trade Balance
  #======================================
  
  df_trade <- reactive({
    req(input$trade_countries, input$trade_year_range)
    df_full %>%
      filter(
        Country %in% input$trade_countries,
        Year >= input$trade_year_range[1],
        Year <= input$trade_year_range[2]
      )
  })
  
  output$selected_trade_countries <- renderText({
    paste(input$trade_countries, collapse = ", ")
  })
  
  output$trade_dynamic_plot <- renderPlotly({
    req(input$trade_indicator)
    
    df_t_all <- df_trade()
    years_selected <- input$trade_year_range
    
    # If “Exports” → line chart Exports over years
    if (input$trade_indicator == "Exports") {
      df_line <- df_t_all %>%
        filter(!is.na(Exports)) %>%
        select(Country, Year, Exports)
      p_exp <- ggplot(df_line, aes(x = Year, y = Exports, color = Country)) +
        geom_line(size = 1) +
        geom_point(size = 2) +
        scale_color_manual(values = country_colors) +
        labs(
          title = "Exports Over Time",
          x = "Year",
          y = "Exports (million USD)"
        ) +
        theme_minimal()
      return(ggplotly(p_exp) %>%
               layout(legend = list(orientation = "h", x = 0.2, y = -0.2)))
    }
    
    # If “Imports” → line chart Imports over years
    if (input$trade_indicator == "Imports") {
      df_line <- df_t_all %>%
        filter(!is.na(Imports)) %>%
        select(Country, Year, Imports)
      p_imp <- ggplot(df_line, aes(x = Year, y = Imports, color = Country)) +
        geom_line(size = 1) +
        geom_point(size = 2) +
        scale_color_manual(values = country_colors) +
        labs(
          title = "Imports Over Time",
          x = "Year",
          y = "Imports (million USD)"
        ) +
        theme_minimal()
      return(ggplotly(p_imp) %>%
               layout(legend = list(orientation = "h", x = 0.2, y = -0.2)))
    }
    
    # If “Trade Balance” → waterfall of aggregated Exports & Imports over range
    df_agg <- df_t_all %>%
      group_by(Country) %>%
      summarise(
        Total_Exports = sum(Exports, na.rm = TRUE),
        Total_Imports = sum(Imports, na.rm = TRUE)
      ) %>%
      ungroup() %>%
      mutate(
        Total_Exports = ifelse(is.na(Total_Exports), 0, Total_Exports),
        Total_Imports = ifelse(is.na(Total_Imports), 0, Total_Imports),
        Net           = Total_Exports - Total_Imports
      )
    
    x_vals <- c()
    y_vals <- c()
    measure_vals <- c()
    
    for (c in df_agg$Country) {
      ex_tot <- df_agg$Total_Exports[df_agg$Country == c]
      im_tot <- df_agg$Total_Imports[df_agg$Country == c]
      x_vals <- c(x_vals,
                  paste(c, "(Exports)"),
                  paste(c, "(Imports)"),
                  paste(c, "(Net)")
      )
      y_vals <- c(y_vals,
                  ex_tot,
                  -im_tot,
                  NA
      )
      measure_vals <- c(measure_vals,
                        "relative",
                        "relative",
                        "total"
      )
    }
    
    p_wf <- plot_ly(
      type    = "waterfall",
      x       = ~x_vals,
      y       = ~y_vals,
      measure = ~measure_vals,
      text    = ~paste0(
        ifelse(y_vals >= 0, "+", ""),
        formatC(y_vals, format = "f", big.mark = ",", digits = 0)
      ),
      textposition = "outside",
      increasing   = list(marker = list(color = "#009990")),
      decreasing   = list(marker = list(color = "#FFB433")),
      totals       = list(marker = list(color = "#074799"))
    ) %>%
      layout(
        title = paste0(
          "Aggregate Exports & Imports Waterfall\nYears: ",
          years_selected[1], "–", years_selected[2]
        ),
        xaxis = list(title = "Country / Flow"),
        yaxis = list(title = "Value (million USD)")
      )
    
    return(p_wf)
  })
  
  output$line_tb <- renderPlotly({
    df_plot <- df_trade() %>%
      select(Country, Year, Trade_Balance)
    p_tb <- ggplot(df_plot, aes(x = Year, y = Trade_Balance, color = Country)) +
      geom_line(size = 1) +
      geom_point(size = 2) +
      scale_color_manual(values = country_colors) +
      labs(
        title = "Trade Balance Over Time",
        x     = "Year",
        y     = "Trade Balance (million USD)"
      ) +
      theme_minimal()
    ggplotly(p_tb) %>%
      layout(legend = list(orientation = "h", x = 0.2, y = -0.2))
  })
  
  output$bubble_trade <- renderPlotly({
    df_plot <- df_trade() %>%
      mutate(Size = GDP_real / 1000)
    p_bub <- ggplot(df_plot, aes(
      x = Trade_Balance,
      y = GDP_real,
      size = Size,
      color = Country,
      text = paste(
        "Country: ", Country,
        "<br>Year: ", Year,
        "<br>TB: ", Trade_Balance,
        "<br>GDP (M USD): ", GDP_real
      )
    )) +
      geom_point(alpha = 0.7) +
      scale_color_manual(values = country_colors) +
      labs(
        title = "Bubble: Trade Balance vs GDP",
        x     = "Trade Balance (million USD)",
        y     = "GDP (million USD)"
      ) +
      theme_minimal()
    ggplotly(p_bub, tooltip = "text")
  })
  
  
  #======================================
  # Tab 3: Financial & Monetary Indicators
  #======================================
  
  df_fm <- reactive({
    req(input$fm_countries, input$fm_year_range)
    df_full %>%
      filter(
        Country %in% input$fm_countries,
        Year >= input$fm_year_range[1],
        Year <= input$fm_year_range[2]
      )
  })
  
  output$kpi_fx_rate <- renderValueBox({
    df1 <- df_fm() %>%
      filter(Year == max(Year, na.rm = TRUE)) %>%
      summarise(val = mean(FX_rate, na.rm = TRUE)) %>%
      pull(val)
    valueBox(
      subtitle = "Avg FX Rate (LCU/USD)",
      value    = ifelse(is.na(df1), "N/A", sprintf("%.2f", df1)),
      icon     = icon("money-bill"),
      color    = "navy"
    )
  })
  
  output$kpi_dummy1 <- renderValueBox({
    valueBox(subtitle = "", value = "", color = "light-blue")
  })
  output$kpi_dummy2 <- renderValueBox({
    valueBox(subtitle = "", value = "", color = "light-blue")
  })
  
  output$line_fx <- renderPlotly({
    df_plot <- df_fm() %>%
      select(Country, Year, FX_rate)
    p_fx <- ggplot(df_plot, aes(x = Year, y = FX_rate, color = Country)) +
      geom_line(size = 1) +
      geom_point(size = 2) +
      scale_color_manual(values = country_colors) +
      labs(
        title = "FX Rate Over Time",
        x     = "Year",
        y     = "FX Rate (LCU per USD)"
      ) +
      theme_minimal()
    ggplotly(p_fx) %>%
      layout(legend = list(orientation = "h", x = 0.2, y = -0.2))
  })
  
}

#-----------------------------------------------------------
# 5. RUN THE APPLICATION
#-----------------------------------------------------------

shinyApp(ui, server)
