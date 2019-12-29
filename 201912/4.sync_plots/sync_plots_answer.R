library(shiny)
library(ggplot2)
library(dplyr)

# reference : 
# https://shiny.rstudio.com/gallery/plot-interaction-basic.html
# https://shiny.rstudio.com/gallery/plot-interaction-zoom.html

data <- mtcars %>% mutate(id = 1:n())

my_theme <- 
  theme_bw() + 
  theme(
    legend.position='none',
    panel.grid = element_blank()) 

ui <- fluidPage(
  fluidRow(
    mainPanel(
      h3('How to Sync Plots'),
      code('hint : reactiveValues, observe')
    )
  ),
  fluidRow(
    column(6, plotOutput('plot1', brush=brushOpts(id='brush'))),
    column(6, plotOutput('plot2'))
  )
)


# 1. with reactiveValues & observe answer ============================

selects <- reactiveValues(xmin=Inf, ymin=Inf, xmax=Inf, ymax=Inf)

server <- function(input, output) {
  
  observe({
    if (!is.null(input$brush)) {
      selects$xmin <- input$brush$xmin
      selects$ymin <- input$brush$ymin
      selects$xmax <- input$brush$xmax
      selects$ymax <- input$brush$ymax
    } else {
      selects$xmin <- Inf
      selects$ymin <- Inf
      selects$xmax <- Inf
      selects$ymax <- Inf
    }
  })
  
  output$plot1 <- renderPlot(
    data %>%
    ggplot(aes(wt, qsec)) + 
      geom_text(aes(label=id)) +
      my_theme +
      labs(title='Operation Window')
  )
  
  output$plot2 <- renderPlot({
    data %>%
      mutate(selected = ifelse(
        wt >= selects$xmin & wt <= selects$xmax & 
        qsec >= selects$ymin & qsec <= selects$ymax, 
        'selected', 'none')
      ) %>%
      ggplot(aes(hp, mpg)) +
      geom_text(aes(label=id, colour=selected)) +
      scale_colour_manual(values=c('gray', 'red')) +
      my_theme +
      labs(title='Result Window')
  })
}

shinyApp(ui, server)


# 2. with brushedPoints answer ============================
# thanks to...! https://www.facebook.com/byungsun.bae.1

server <- function(input, output) {
  
  output$plot1 <- renderPlot(
    data %>%
      ggplot(aes(wt, qsec)) + 
      geom_text(aes(label=id)) +
      my_theme +
      labs(title='Operation Window')
  )
  
  output$plot2 <- renderPlot({
    data %>%
      brushedPoints(input$brush, allRows=TRUE) %>%
      ggplot(aes(hp, mpg)) +
      geom_text(aes(label=id, colour=selected_)) +
      scale_colour_manual(values=c('gray', 'red')) +
      my_theme +
      labs(title='Result Window')
  })
}

shinyApp(ui, server)
