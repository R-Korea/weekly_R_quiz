library(dplyr)
library(sf)
library(leaflet)
library(shiny)

rm(list=ls())

ui <- fluidPage(
  h1('District Maker'),
  fluidRow(
    column(8, leafletOutput('map', width='800px', height='600px')),
    column(3, 
      textInput('save_file_name', label=h3('Save File Name'), value = 'districts.RDS'),
      actionButton('make_polygon', '구역 생성'),
      actionButton('clear', '지우기'),
      actionButton('save_polygons', '저장')
    )
  )
)

server <- function(input, output){

  rv <- reactiveValues(
    clicks = data.frame(lng = numeric(), lat = numeric()),
    polygons = list()
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
  
  # make_polygon button click
  observeEvent(input$make_polygon, {
    if(nrow(rv$clicks) > 0){ # at least 1 point
      rv$clicks <- bind_rows(rv$clicks, rv$clicks[1,]) # add first point (= to make close polygon)
      new.polygon <- rv$clicks %>% as.matrix %>% list(.) %>% st_polygon # make polygon
      rv$polygons[[length(rv$polygons) + 1]] <- new.polygon # append to polygon list
      rv$clicks <- data.frame(lng = numeric(), lat = numeric()) # reset clicks
    }
  })
  
  # clear button click
  observeEvent(input$clear, {
    rv$clicks <- data.frame(lng = numeric(), lat = numeric())
    rv$polygons <- list()
  })
  
  # save_polygons button click
  observeEvent(input$save_polygons, {
    rv$polygons %>% 
      st_sfc %>% 
      saveRDS(input$save_file_name)
    
    save.file.message <- 
      paste('polygons are saved at: ', getwd(), '/', input$save_file_name, sep='')
    
    print(save.file.message)
  })
  
  # make view
  output$map <- {
    renderLeaflet({
      if(is.null(input$map_click)){ # initial view
        leaflet() %>% 
          addTiles() %>% 
          setView(lat=37.56579, lng=126.9386, zoom=15)
      }else if(length(rv$polygons) > 0){ # with polygons
        leaflet() %>% 
          addTiles() %>% 
          addCircles(data=rv$clicks, lng=~lng, lat=~lat, radius=3, color='red') %>%
          addPolylines(data=rv$clicks, lng=~lng, lat=~lat, weight=2, dashArray=3, color='red') %>%
          addPolygons(data=rv$polygons %>% st_sfc, weight=1, color='red', fillColor='red', fillOpacity=.5) %>%
          setView(lat=input$map_center$lat, lng=input$map_center$lng, zoom=input$map_zoom)
      }else{ # without polygons
        leaflet() %>% 
          addTiles() %>% 
          addCircles(data=rv$clicks, lng=~lng, lat=~lat, radius=3, color='red') %>%
          addPolylines(data=rv$clicks, lng=~lng, lat=~lat, weight=2, dashArray=3, color='red') %>%
          setView(lat=input$map_center$lat, lng=input$map_center$lng, zoom=input$map_zoom)
      }
    })
  }
}

shinyApp(ui, server)
