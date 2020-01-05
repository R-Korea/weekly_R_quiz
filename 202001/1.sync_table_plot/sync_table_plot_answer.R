library(dplyr)
library(data.table)
library(leaflet)
library(DT)
library(shiny)

# reference : 
# https://yihui.shinyapps.io/DT-rows/
# https://rstudio.github.io/DT/shiny.html
# https://rstudio.github.io/leaflet/basemaps.html

input.gist <- 
  'https://gist.githubusercontent.com/Curycu/1b913d73e16c9811c75efebe20cebf57/raw/a6e3b0ead49ad19f0e40e59c36ad8021fecff877/sync_table_plot.csv'

data <-
  fread(input.gist, encoding='UTF-8') %>%
  mutate(id = 1:n(), selected = FALSE)

ui <- fluidPage(
  h1('Sync Table & Plot'),
  
  fluidRow(
    column(6, DT::dataTableOutput('t1')),
    column(6, leafletOutput('m1', height = 500))
  )
)

server <- function(input, output){
  output$t1 <- DT::renderDataTable(
    data %>% select(id, name), 
    rownames=FALSE,
    selection=list(mode='multiple', selected=c(3, 7, 9, 10), target='row'),
    options=list(pageLength=6))
  
  output$m1 <- renderLeaflet({
    data$selected[input$t1_rows_selected] <- TRUE
    
    leaflet() %>%
      addProviderTiles(providers$Stamen.Toner) %>% 
      addMarkers(
        lng=data$lng, 
        lat=data$lat, 
        popup=data$name, 
        options=markerOptions(opacity=ifelse(data$selected, 1, .3))
      )
  })
}

shinyApp(ui, server)