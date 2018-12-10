library(tidyverse)
library(maps)
library(mapproj)
library(shiny)

# counties <- readRDS("Shiny_Test//census-app/data/counties.rds")
# counties <- as.tibble(counties)
# # to use precent_map
# source('Shiny_Test//census-app/helpers.R')

# percent_map(counties$white, 'darkgreen', '% White')

# Path:
#   1. When the server script is running, the directory of server.R
# is seen as the default file path.
#   2. ui.R only run once when the app is launched;
# server.R run once each time a user visits the app;
# render* function run once each time any widget is changed.

counties <- readRDS("data/counties.rds")
source("helpers.R")

ui <- fluidPage(
  titlePanel('cencusVis'),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create demographic maps with 
        information from the 2010 US Census."),
      
      selectInput(
        "var", 
        label = "Choose a variable to display",
        choices = c("Percent White", "Percent Black",
                    "Percent Hispanic", "Percent Asian"),
        selected = "Percent White"
      ),
      
      sliderInput("range", 
                  label = "Range of interest:",
                  min = 0, max = 100, value = c(0, 100))
    ),
    
    mainPanel(plotOutput('map'))
    
  )
)

server <- function(input, output){
  output$map <- renderPlot({
    data <- switch(
      input$var,
      "Percent White" = counties$white,
      "Percent Black" = counties$black,
      "Percent Hispanic" = counties$hispanic,
      "Percent Asian" = counties$asian
    )
    percent_map(data, color = 'darkgreen',
                legend.title = input$var,
                input$range[1], input$range[2])
  })
}

shinyApp(ui, server)
