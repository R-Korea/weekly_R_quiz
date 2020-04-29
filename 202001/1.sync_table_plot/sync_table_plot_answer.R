library(dplyr)
library(data.table)
library(leaflet)
library(DT)
library(shiny)

# reference : 
# https://yihui.shinyapps.io/DT-rows/
# https://rstudio.github.io/DT/shiny.html
# https://rstudio.github.io/leaflet/basemaps.html

ui <- fluidPage(
  h1('Sync Table & Plot'),
  
  fluidRow(
    column(6, DT::dataTableOutput('table')),
    column(6, leafletOutput('map', height = 500))
  )
)

server <- function(input, output){

  input.gist <- 
    'https://gist.githubusercontent.com/Curycu/1b913d73e16c9811c75efebe20cebf57/raw/a6e3b0ead49ad19f0e40e59c36ad8021fecff877/sync_table_plot.csv'
  
  data =
    fread(input.gist, encoding='UTF-8') %>%
    mutate(id = 1:n(), selected = FALSE)
  
  output$table <- DT::renderDataTable(
    data %>% select(id, name), 
    rownames=FALSE,
    selection=list(mode='multiple', selected=c(3, 7, 9, 10), target='row'),
    options=list(pageLength=10)
  )
  
  output$map <- renderLeaflet({
    synced.data <-
      data %>% 
      mutate(selected = ifelse(id %in% input$table_rows_selected, TRUE, FALSE))
    
    leaflet() %>%
      addProviderTiles(providers$Stamen.Toner) %>%
      addMarkers(
        data=synced.data,
        lng=~lng, 
        lat=~lat, 
        popup=~name, 
        options=markerOptions(opacity=ifelse(synced.data$selected, 1, .3)))
  })
}

shinyApp(ui, server)