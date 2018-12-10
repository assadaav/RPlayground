library(shiny)

ui <- fluidPage(
  titlePanel(h1('My Shiny App')),
  sidebarLayout(
    sidebarPanel(
      h3('Ins'),
      p('blahblah'),
      code('Hello World'),
      img(src = 'rstudio.png'),
      p('blahblah', span('blue text ', style = 'color:blue'), 'blahblah')
    ),
    mainPanel(
      h2('Intro'),
      p('lll'),
      br(),
      p('blahblah',
        a('hyper', href = 'http://www.bing.com'))
    )
  )
)

server <- function(input, output){
  
}

shinyApp(ui = ui, server = server)