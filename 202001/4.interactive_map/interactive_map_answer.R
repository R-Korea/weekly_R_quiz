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
      selectInput('region', '구역:', choices=c('여의도'=1, '팔달문'=2), selected=2),
      actionButton('clear', '비우기'),
      actionButton('all', '전체 선택'),
      h3(''),
      textOutput('revenue')
    )
  )
)

server <- function(input, output){

  rv <- reactiveValues(
    base.data = NULL,
    data = NULL
  )
  
  # dropdown : select region
  observeEvent(input$region, {
    rv$base.data <- if(input$region == 1){
      yeoeuido
    }else if(input$region == 2){
      paldalmun
    }else{
      yeoeuido
    }
    rv$data <- rv$base.data
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
  })
  
  # if values of rv$data are changed then re-draw leaflet plot
  observe({
    # polygon viz
    hos <- highlightOptions(weight=5, color='white', dashArray='', bringToFront=TRUE)
    
    # polygon label viz
    labels <- sprintf('<strong>%s</strong><br/>매출: %s원', rv$data$name, comma(rv$data$value)) %>% lapply(HTML)
    los <- labelOptions(style=list('font-weight'='normal', padding='3px 8px'), textsize='15px', direction='auto')
    
    # label only marker viz
    marker.labels <- sprintf('<strong>%s</strong>', comma(rv$data$value)) %>% lapply(HTML)
    marker.los <- labelOptions(noHide=TRUE, direction='center', textOnly=TRUE, textsize='12px')
    centers <- suppressWarnings(st_centroid(rv$data))
    
    leafletProxy('map') %>%
      removeShape(layerId=input$map_shape_click$id) %>%
      removeMarker(layerId=input$map_shape_click$id) %>%
      addPolygons(
        data=rv$data,
        color='white', weight=2, opacity=1, dashArray=3, 
        fillColor=colorBin('Blues', domain=NULL)(rv$data$value), 
        fillOpacity=ifelse(rv$data$clicked, 1, 0),
        highlight=hos, label=labels, labelOptions=los,
        layerId=rv$data$id
      ) %>%
      addLabelOnlyMarkers(
        data=centers,
        label=marker.labels, labelOptions=marker.los,
        layerId=paste('center', rv$data$id, sep='_'))
  })
  
  # make view
  output$map <- renderLeaflet({
    
    # polygon viz
    hos <- highlightOptions(weight=5, color='white', dashArray='', bringToFront=TRUE)
    
    # polygon label viz
    labels <- sprintf('<strong>%s</strong><br/>매출: %s원', rv$base.data$name, comma(rv$base.data$value)) %>% lapply(HTML)
    los <- labelOptions(style=list('font-weight'='normal', padding='3px 8px'), textsize='15px', direction='auto')

    # label only marker viz
    marker.labels <- sprintf('<strong>%s</strong>', comma(rv$base.data$value)) %>% lapply(HTML)
    marker.los <- labelOptions(noHide=TRUE, direction='center', textOnly=TRUE, textsize='12px')
    centers <- suppressWarnings(st_centroid(rv$base.data))
    
    leaflet() %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      addPolygons(
        data=rv$base.data,
        color='white', weight=2, opacity=1, dashArray=3, 
        fillColor=colorBin('Blues', domain=NULL)(rv$base.data$value), 
        fillOpacity=1,
        highlight=hos, label=labels, labelOptions=los,
        layerId=rv$base.data$id
      ) %>%
      addLabelOnlyMarkers(
        data=centers,
        label=marker.labels, labelOptions=marker.los,
        layerId=paste('center', rv$base.data$id, sep='_')) %>%
      addLegend(
        values=rv$base.data$value,
        pal=colorBin('Blues', domain=summary(rv$base.data$value)[c(1,6)]),
        title=NULL, opacity=.7, position='bottomright')
  })
  
  # calculate revenue
  output$revenue <- renderText({
    
    if(is.null(rv$data)){
      rv$data <- rv$base.data
    }
    
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
