library(dplyr)
library(sf)

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(stringr)

library(leaflet)
library(ggplot2)
library(scales)
library(DT)

library(curl)
library(showtext)

rm(list=ls())

# pre setting ==================

font_add_google('Nanum Gothic', 'nanum')
showtext_auto()

set.seed(20201115)

geo.data <- 
  readRDS('korea.RDS') %>%
  mutate(name = factor(x=name))
  
regions <- 
  geo.data %>% 
  as.data.frame %>%
  distinct(region.code, region) %>%
  arrange(region.code)

region.menu <- regions$region.code
names(region.menu) <- regions$region
  
date.formatter <- function(d) format(d, '%Y-%m-%d')
start.date <- date.formatter(Sys.Date() - 31) 
end.date <- date.formatter(Sys.Date() - 1) 

hour.formatter <- function(h) as.character(h) %>% str_pad(width=2, pad='0')
hour.1q <- hour.formatter(0:5)
hour.2q <- hour.formatter(6:11)
hour.3q <- hour.formatter(12:17)
hour.4q <- hour.formatter(18:23)
  
value.data.size <- nrow(geo.data) * 20

value.data <-
  data.frame(
    code = geo.data$code,
    date = date.formatter(Sys.Date() + sample(0:-50, size=value.data.size, replace=TRUE)),
    hour = hour.formatter(sample(0:23, size=value.data.size, replace=TRUE)),
    value = floor(runif(value.data.size)*100),
    stringsAsFactors = FALSE
  )

# ui ==================

h <- dashboardHeader(disable=TRUE)
s <- dashboardSidebar(disable=TRUE)
b <- dashboardBody(
   h3('GIS Interactive BI Etude'),
   fluidRow(
     tabBox(width=8,
       tabPanel('map', leafletOutput('map', height='700px')),
       tabPanel('chart', plotOutput('chart')),
       tabPanel('table', DT::dataTableOutput('table'))
     ),
     box(width=4,
       selectInput('region.code', label='Region', choices=region.menu, selected='11'),
       dateRangeInput('dates', label='Date Range', start=start.date, end=end.date),
       checkboxGroupButtons('hours.1q', label='Hour Filter', choices=hour.1q, selected=hour.1q),
       checkboxGroupButtons('hours.2q', label=NULL, choices=hour.2q, selected=hour.2q),
       checkboxGroupButtons('hours.3q', label=NULL, choices=hour.3q, selected=hour.3q),
       checkboxGroupButtons('hours.4q', label=NULL, choices=hour.4q, selected=hour.4q),
       actionButton('run', label='Get Data'),
       downloadButton('download', label='Download')
     )
   )
)

ui <- dashboardPage(h, s, b)

# server ==================

server <- function(input, output){
  rv <- reactiveValues()
  
  init.data <- function(){ # redraw entire map
    rv$data <- 
      geo.data %>%
      filter(region.code == input$region.code) %>%
      inner_join(value.data, by='code') %>%
      filter(
        date >= input$dates[1],
        date <= input$dates[2],
        hour %in% c(input$hours.1q, input$hours.2q, input$hours.3q, input$hours.4q)
      )
  }
  
  init.map.data <- function(){ # redraw entire polygons
    rv$map.data <- 
      rv$data %>%
      mutate(clicked = FALSE) %>%
      group_by(code, name, region.code, region, clicked) %>%
      summarise(value = sum(value)) %>%
      ungroup
    
    output$map <- renderLeaflet({
      leaflet() %>% 
        addTiles() %>%
        addPolygons(
          data=rv$data, 
          weight=1, 
          color='black', 
          layerId=rv$data$code
        )
    })
  }
  
  update.chart.data <- function(){
    rv$chart.data <-
      rv$map.data %>% 
      filter(clicked) %>%
      as.data.frame %>%
      select(code) %>%
      inner_join(rv$data, by='code') %>%
      group_by(code, name, region.code, region, date) %>%
      summarise(value = sum(value)) %>%
      ungroup
  }
  
  update.table.data <- function(){
    rv$table.data <-
      rv$map.data %>% 
      filter(clicked) %>%
      as.data.frame %>%
      select(code) %>%
      inner_join(rv$data, by='code') %>%
      as.data.frame %>%
      arrange(code, date, hour) %>%
      select(name, date, hour, value)
  }
  
  update.all <- function(){
    init.data()
    init.map.data()
    update.chart.data()
    update.table.data()
    print('query running...')
  }
  
  observeEvent(input$map_shape_click, { 
    if(is.null(rv$map.data)) init.map.data()
    
    # map polygon click on/off
    clicked.map.data <- rv$map.data[rv$map.data$code == input$map_shape_click$id, ]
    before_state <- clicked.map.data$clicked
    clicked.map.data$clicked <- !before_state
    rv$map.data[rv$map.data$code == clicked.map.data$code, ]$clicked <- clicked.map.data$clicked
    
    # redraw clicked polygon only
    leafletProxy('map') %>% 
      removeShape(layerId=input$map_shape_click$id) %>%
      removeMarker(layerId=input$map_shape_click$id) %>%
      addPolygons(
        data=clicked.map.data, 
        weight=1, 
        color=ifelse(clicked.map.data$clicked, 'red', 'black'), 
        layerId=clicked.map.data$code
      )
    
    update.chart.data()
    update.table.data()
  })
  
  observeEvent(input$run, {
    update.all()
  })
  
  output$chart <- renderPlot({
    if(is.null(rv$chart.data)){
      NULL
    }else{
      rv$chart.data %>%
        ggplot(aes(x=as.Date(date), y=value, color=name)) +
        geom_point() +
        geom_line(stat='identity', lty='dashed') +
        theme_bw(base_family='nanum') +
        theme(
          axis.title = element_blank(), 
          axis.text.x = element_text(angle=30), 
          legend.position='bottom'
        ) +
        scale_x_date(date_labels = '%m-%d', date_breaks='3 days') +
        scale_y_continuous(labels=comma) +
        labs(title='Daily Trend Chart', color=NULL)
    }
  })
  
  output$table <- DT::renderDataTable(
    rv$table.data,
    rownames=FALSE,
    selection=list(mode='multiple', target='row'),
    options=list(pageLength=10)
  )
  
  output$download <- downloadHandler(
    filename = function(){ paste("bi_etude_", Sys.Date(), ".csv", sep="") },
    content = function(file) { write.csv(rv$table.data, file, row.names=FALSE) }
  )
}

# run ==================

shinyApp(ui, server)
 