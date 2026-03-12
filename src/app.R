library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)
library(readr)

data <- read_csv("../raw/tech_employment_2000_2025.csv")

companies <- sort(unique(data$company))
years <- sort(unique(data$year))

default_company <- if (length(companies) > 0) companies[1] else NULL
default_year_min <- if (length(years) > 0) min(years) else 2000
default_year_max <- if (length(years) > 0) max(years) else 2025

hiring_metrics <- c(
  "Net Change" = "net_change",
  "New Hires" = "new_hires",
  "Hiring Rate %" = "hiring_rate_pct"
)

ui <- page_sidebar(
  title = "Layoff Lens: Tech Workforce Dashboard",
  sidebar = sidebar(
    h2("Filters"),
    selectizeInput(
      "company",
      "Select Companies:",
      choices = companies,
      selected = default_company,
      multiple = TRUE
    ),
    sliderInput(
      "year",
      "Select Year Range:",
      min = default_year_min,
      max = default_year_max,
      value = c(default_year_min, default_year_max),
      sep = "",
      step = 1
    ),
    selectInput(
      "hiring_metric",
      "Hiring Metric:",
      choices = hiring_metrics
    ),
    actionButton("reset", "Reset All Filters"),
    hr(),
    helpText(
      "Note: High hiring spikes can precede consolidation. Use the Hire-Layoff ratio to assess long-term stability."
    )
  ),
  
  card(
    card_header("Company Hiring & Layoff Trends"),
    plotlyOutput("company_trend_plot")
  ),
  
  card(
    card_header("Company Revenue in Billions USD"),
    plotlyOutput("revenue_in_billions")
  ),
  
  layout_columns(
    value_box(
      title = textOutput("ratio_title"),
      value = textOutput("hire_layoff_ratio")
    ),
    value_box(
      title = textOutput("metric_title"),
      value = textOutput("total_hires_val")
    ),
    value_box(
      title = "Total Layoffs",
      value = textOutput("total_layoffs_val")
    )
  )
)

server <- function(input, output, session) {
  
  filtered_df <- reactive({
    req(input$company)
    
    data %>%
      filter(
        company %in% input$company,
        year >= input$year[1],
        year <= input$year[2]
      )
  })
  
  output$revenue_in_billions <- renderPlotly({
    df <- filtered_df()
    if (nrow(df) == 0) return(NULL)
    
    p <- ggplot(df, aes(x = factor(year), y = revenue_billions_usd, fill = company)) +
      geom_col(position = "dodge") +
      labs(x = "Year", y = "Revenue (Billions USD)") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$company_trend_plot <- renderPlotly({
    df <- filtered_df()
    if (nrow(df) == 0) return(NULL)
    
    metric <- input$hiring_metric
    metric_label <- names(hiring_metrics)[hiring_metrics == metric]
    
    p <- ggplot(df, aes(x = factor(year), y = .data[[metric]], color = company, group = company)) +
      geom_line() +
      geom_point() +
      labs(x = "Year", y = metric_label) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$ratio_title <- renderText({
    if (input$hiring_metric == "hiring_rate_pct") return("Avg Hiring Rate")
    metric_label <- names(hiring_metrics)[hiring_metrics == input$hiring_metric]
    paste(metric_label, "/ Layoff Ratio")
  })
  
  output$metric_title <- renderText({
    metric_label <- names(hiring_metrics)[hiring_metrics == input$hiring_metric]
    if (input$hiring_metric == "hiring_rate_pct") return(paste("Avg", metric_label))
    paste("Total", metric_label)
  })
  
  output$hire_layoff_ratio <- renderText({
    df <- filtered_df()
    hires <- sum(df$new_hires, na.rm = TRUE)
    layoffs <- sum(df$layoffs, na.rm = TRUE)
    
    if (layoffs == 0) return("N/A")
    round(hires / layoffs, 2)
  })
  
  output$total_hires_val <- renderText({
    df <- filtered_df()
    sum(df$new_hires, na.rm = TRUE)
  })
  
  output$total_layoffs_val <- renderText({
    df <- filtered_df()
    sum(df$layoffs, na.rm = TRUE)
  })
  
  observeEvent(input$reset, {
    updateSelectizeInput(session, "company", selected = default_company)
    updateSliderInput(session, "year", value = c(default_year_min, default_year_max))
    updateSelectInput(session, "hiring_metric", selected = "net_change")
  })
}

shinyApp(ui, server)