library(dplyr)
library(sf)
library(shiny)
library(leaflet)
library(htmltools)
library(scales)

rm(list=ls())

yeoeuido <- readRDS('yeoeuido.RDS') 
paldalmun <- readRDS('paldalmun.RDS') 

ui <- fluidPage(
  h1('매출 시뮬레이터'),
  fluidRow(
    column(7, leafletOutput('map', height='800px')),
    column(3, 
      selectInput('region', '구역:', c('여의도'=1, '팔달문'=2)),
      actionButton('clear', '비우기'),
      actionButton('all', '전체 선택'),
      h3(''),
      textOutput('revenue')
    )
  )
)

server <- function(input, output){

  rv <- reactiveValues(
    data = yeoeuido,
    refresh = FALSE 
  )
  
  # dropdown : select region
  observeEvent(input$region, {
    rv$data <- if(input$region == 1){
      yeoeuido
    }else if(input$region == 2){
      paldalmun
    }else{
      yeoeuido
    }
    
    # TRUE -> refresh view
    rv$refresh <- TRUE
  })
  
  # button click : select all
  observeEvent(input$all, {
    rv$data <- rv$data %>% mutate(clicked=TRUE)
  })
  
  # button click : clear
  observeEvent(input$clear,{
    rv$data <- rv$data %>% mutate(clicked=FALSE)
  })
  
  # view (=polygons) click
  observeEvent(input$map_shape_click, {
    # check map polygon selection : on/off
    before_state <- rv$data[rv$data$id == input$map_shape_click$id, ]$clicked
    rv$data[rv$data$id == input$map_shape_click$id, ]$clicked <- !before_state
    
    # FALSE -> maintain previous view : lng, lat, zoom
    rv$refresh <- FALSE
  })
  
  # make view
  output$map <- renderLeaflet({
    
    # polygon label info
    centers <-
      suppressWarnings(st_centroid(rv$data))

    labels <-
      sprintf(
        '<strong>%s</strong><br/>매출: %s원',
        rv$data$name,
        comma(rv$data$value)
      ) %>%
      lapply(HTML)

    los <-
      labelOptions(
        style=list('font-weight'='normal', padding='3px 8px'),
        textsize='15px',
        direction='auto'
      )

    hos <-
      highlightOptions(
        weight=5,
        color='white',
        dashArray='',
        bringToFront=TRUE
      )

    # marker label info
    marker.labels <-
      sprintf(
        '<strong>%s</strong>',
        comma(rv$data$value)
      ) %>%
      lapply(HTML)

    marker.los <-
      labelOptions(
        noHide=TRUE,
        direction='center',
        textOnly=TRUE,
        textsize='12px'
      )
    
    # leaflet making
    if(length(input$map_shape_click) == 0 | rv$refresh){ # TRUE -> refresh view
      
      leaflet() %>%
        addProviderTiles(providers$CartoDB.DarkMatter) %>%
        addPolygons(
          data=rv$data,
          color='white', 
          weight=2, 
          opacity=1, 
          dashArray=3, 
          fillColor=colorBin('Blues', domain=NULL)(rv$data$value),
          fillOpacity=ifelse(rv$data$clicked, 1, 0),
          highlight=hos,
          label=labels,
          labelOptions=los,
          layerId=rv$data$id
        ) %>%
        addLabelOnlyMarkers(
          data=centers,
          label=marker.labels,
          labelOptions=marker.los
        ) %>%
        addLegend(
          pal=colorBin('Blues', domain=summary(rv$data$value)[c(1,6)]),
          values=rv$data$value,
          opacity=.7,
          title=NULL,
          position='bottomright'
        )
      
    }else{ # FALSE -> maintain previous view : lng, lat, zoom
      
      leaflet() %>%
        addProviderTiles(providers$CartoDB.DarkMatter) %>%
        addPolygons(
          data=rv$data,
          color='white', 
          weight=2, 
          opacity=1, 
          dashArray=3, 
          fillColor=colorBin('Blues', domain=NULL)(rv$data$value),
          fillOpacity=ifelse(rv$data$clicked, 1, 0),
          highlight=hos,
          label=labels,
          labelOptions=los,
          layerId=rv$data$id
        ) %>%
      addLabelOnlyMarkers(
        data=centers,
        label=marker.labels,
        labelOptions=marker.los
      ) %>%
      addLegend(
        pal=colorBin('Blues', domain=summary(rv$data$value)[c(1,6)]),
        values=rv$data$value,
        opacity=.7,
        title=NULL,
        position='bottomright'
      ) %>%
      setView( # previous view : lng, lat, zoom
        lat=input$map_center$lat, 
        lng=input$map_center$lng, 
        zoom=input$map_zoom
      )
    }
  })
  
  # calculate revenue
  output$revenue <- renderText({
    res <-
      rv$data %>%
      filter(clicked) 
    
    if(nrow(res) > 0){
      res %>%
        summarise(value = sum(value)) %>%
        as.data.frame %>%
        transmute(value = ifelse(is.na(value), '0', comma(value))) %>%
        unlist %>%
        paste('매출 : ', ., '원', sep='')
    }else{
      '매출 : 0원'
    }
  })
}

shinyApp(ui, server)
