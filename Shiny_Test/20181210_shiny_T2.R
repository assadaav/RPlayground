library(shiny)

# fluidPage for self-adjusted browser
ui <- fluidPage(
  titlePanel(h1("title")), # html lang
  
  sidebarLayout(
    position = 'right',
    sidebarPanel(
      h6('sb'), align = 'center'
    ),
    mainPanel(
      'main', br(),
      img(src = 'rstudio.png', height = 140, width = 400),
      # images must be stored in a folder named 'www'
      p("p creates a paragraph of text."),
      p("A new p() command starts a new paragraph. Supply a style attribute to change the format of the entire paragraph.", style = "font-family: 'times'; font-si16pt"),
      strong("strong() makes bold text."),
      em("em() creates italicized (i.e, emphasized) text."),
      br(),
      code("code displays your text similar to computer code"),
      div("div creates segments of text with a similar style. This division of text is all blue because I passed the argument 'style = color:blue' to div", style = "color:blue"),
      br(),
      p("span does the same thing as div, but it works with",
        span("groups of words", style = "color:blue"),
        "that appear inside a paragraph.")
    )
  )
)

server <- function(input, output){
  
}

shinyApp(ui = ui, server = server)
