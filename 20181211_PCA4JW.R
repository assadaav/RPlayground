library(shiny)
library('DT')

ui <- fluidPage(
  titlePanel(h1('A PCA minitool')),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", h3("File input")),
      helpText("Caution: Patient ID in the first colomn and gene names in the first row."),
      textInput("nc", h3("Name of nc. Multiple input seperate"), 
                value = "b-actin,")
    ),
    mainPanel(
      
    )
  )
)

server <- function(input, output, session) {
  
}

shinyApp(ui, server)