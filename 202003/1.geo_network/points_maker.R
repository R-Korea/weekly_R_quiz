library(dplyr)
library(sf)
library(leaflet)
library(shiny)

rm(list=ls())

ui <- fluidPage(
  h1('Points Maker'),
  fluidRow(
    column(8, leafletOutput('map', width='800px', height='600px')),
    column(3, 
           textInput('save_file_name', label=h3('Save File Name'), value = 'points.RDS'),
           actionButton('clear', '지우기'),
           actionButton('save_points', '저장')
    )
  )
)

server <- function(input, output){
  rv <- reactiveValues(
    clicks = data.frame(lng = numeric(), lat = numeric())
  )
  
  # map click
  observeEvent(input$map_click, {
    lastest.click <- 
      data.frame(
        lng = input$map_click$lng, 
        lat = input$map_click$lat
      )
    
    rv$clicks <- 
      bind_rows(rv$clicks, lastest.click) # add new point
  })
  
  # clear button click
  observeEvent(input$clear, {
    rv$clicks <- data.frame(lng = numeric(), lat = numeric())
  })
  
  # save_points button click
  observeEvent(input$save_points, {
    raw.data <-
      rv$clicks %>% 
      mutate(
        idx = 1:n(), 
        direction = ifelse(idx %% 2 == 0, 'from', 'to'))
    
    from.data <- 
      raw.data %>% 
      filter(direction == 'from') %>%
      mutate(idx = 1:n())
    
    to.data <- 
      raw.data %>% 
      filter(direction == 'to') %>%
      mutate(idx = 1:n())
    
    data <-
      from.data %>%
      inner_join(to.data, by='idx') %>%
      transmute(
        idx, 
        from_lng = lng.x,
        from_lat = lat.x,
        to_lng = lng.y,
        to_lat = lat.y) 
    
    saveRDS(data, input$save_file_name)
    
    save.file.message <- 
      paste('points are saved at: ', getwd(), '/', input$save_file_name, sep='')
    
    print(save.file.message)
  })
  
  # make view
  output$map <- {
    renderLeaflet({
      if(is.null(input$map_click)){ # initial view
        leaflet() %>% 
          addTiles() %>% 
          setView(lat=37.56579, lng=126.9386, zoom=17)
      }else{ 
        leaflet() %>% 
          addTiles() %>% 
          addCircles(data=rv$clicks, lng=~lng, lat=~lat, radius=3, color='red') %>%
          setView(lat=input$map_center$lat, lng=input$map_center$lng, zoom=input$map_zoom)
      }
    })
  }
}

shinyApp(ui, server)
