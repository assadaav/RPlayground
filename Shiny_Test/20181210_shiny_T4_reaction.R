ui <- fluidPage(
  titlePanel("censusVis"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create demographic maps with 
               information from the 2010 US Census."),
      
      selectInput("var", # name
                  label = "Choose a variable to display",
                  choices = c("Percent White", 
                              "Percent Black",
                              "Percent Hispanic", 
                              "Percent Asian"),
                  selected = "Percent White"),
      
      sliderInput("range", # name
                  label = "Range of interest:",
                  min = 0, max = 100, value = c(0, 100))
    ),
    
    # Each *Output function needs a para as output name
    mainPanel(
      textOutput("selected_var"),
      br(),
      textOutput("slider_var")
    )
  )
)


# dataTableOutput	DataTable
# htmlOutput	raw HTML
# imageOutput	image
# plotOutput	plot
# tableOutput	table
# textOutput	text
# uiOutput	raw HTML
# verbatimTextOutput	text

server <- function(input, output){
  # variable names should be same with those in the *Output function
  # Caution: render* function need ({})
  # input: storing all wigets by their name
  output$selected_var <- renderText({
    paste0('Current active: ', input$var)
  })
  
  output$slider_var <- renderText({
    paste0('It goes from ', input$range[1],
           ' to ', input$range[2])
  })
}

# renderDataTable	DataTable
# renderImage	images (saved as a link to a source file)
# renderPlot	plots
# renderPrint	any printed output
# renderTable	data frame, matrix, other table like structures
# renderText	character strings
# renderUI	a Shiny tag object or HTML

shinyApp(ui = ui, server = server)