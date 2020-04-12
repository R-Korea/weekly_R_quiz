library(leaflet)
library(shiny)
library(sf)
library(dplyr)
library(scales)

rm(list=ls())

ui <- fluidPage(
  h1('이벤트 참여 시뮬레이션'),
  fluidRow(
    column(8, leafletOutput('map', width='1000px', height='800px')),
    column(4, 
      sliderInput('in_radius', label='이벤트 참여인정 반경 (meter)', min=10, max=500, value=300),
      sliderInput('near_radius', label='이벤트 확인가능 반경 (meter)', min=500, max=3000, value=500),
      tableOutput('table'))
  )
)

server <- function(input, output){

  markers <- readRDS('markers.RDS')
  users <- readRDS('users.RDS')
  
  rv <- reactiveValues(
    markers.in = NULL,
    markers.near = NULL,
    result = NULL
  )
  
  # make map
  output$map <- renderLeaflet({
    
    # transform for meter calculation
    markers.wtm <- markers %>% st_transform(crs=5181)
    
    # draw circles based on center point & radius
    # transform to longlat crs & union
    rv$markers.in <- markers.wtm %>% st_buffer(dist=input$in_radius) %>% st_transform(crs=4326) %>% st_union
    rv$markers.near <- markers.wtm %>% st_buffer(dist=input$near_radius) %>% st_transform(crs=4326) %>% st_union
    
    if(is.null(input$map_center)){ # initial view
      leaflet() %>%
        addTiles %>%
        addMarkers(data=markers) %>%
        addPolygons(data=rv$markers.in, color='red', fillOpacity=.3, opacity=0) %>%
        addPolygons(data=rv$markers.near, color='red', fillOpacity=0, opacity=1, weight=2, dashArray=5)
    }else if(is.null(rv$result)){ # not initial view : maintain map view position
      leaflet() %>%
        addTiles %>%
        addMarkers(data=markers) %>%
        addPolygons(data=rv$markers.in, color='red', fillOpacity=.3, opacity=0) %>%
        addPolygons(data=rv$markers.near, color='red', fillOpacity=0, opacity=1, weight=2, dashArray=5) %>%
        setView(lat=input$map_center$lat, lng=input$map_center$lng, zoom=input$map_zoom)
    }else{ # after calculation view : display users on the map 
      leaflet() %>%
        addTiles %>%
        addMarkers(data=markers) %>%
        addPolygons(data=rv$markers.in, color='red', fillOpacity=.3, opacity=0) %>%
        addPolygons(data=rv$markers.near, color='red', fillOpacity=0, opacity=1, weight=2, dashArray=5) %>%
        addCircles(data=users, color='black', weight=3, opacity=0, fillOpacity=1) %>%
        setView(lat=input$map_center$lat, lng=input$map_center$lng, zoom=input$map_zoom)
    }
  })
  
  # make table
  output$table <- renderTable({
    rv$result <-
      data.frame(
        is_near = users %>% st_intersects(rv$markers.near, sparse=FALSE),
        is_in = users %>% st_intersects(rv$markers.in, sparse=FALSE),
        stringsAsFactors=FALSE)
    
    data.frame(
      total_users = rv$result %>% nrow,
      near_users = rv$result %>% filter(is_near) %>% nrow,
      event_users = rv$result %>% filter(is_in) %>% nrow,
      stringsAsFactors=FALSE) %>% 
      mutate(
        event_near_ratio = percent(event_users / near_users),
        total_users = comma(total_users),
        near_users = comma(near_users),
        event_users = comma(event_users)
      )
    
  })
}

shinyApp(ui, server)
