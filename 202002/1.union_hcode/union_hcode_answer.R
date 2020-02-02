library(dplyr)
library(leaflet)

rm(list=ls())

(data <- readRDS('polygons.RDS'))

simple_view <- function(data){
  leaflet(data) %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addPolygons(weight=1, color='black', fillOpacity=.3)
}

union_hcode <- function(data, digit=10){
  data %>%
    mutate(id = substring(id, 1, digit)) %>%
    group_by(id) %>%
    summarise(count = n())
}

union_hcode(data) %>% simple_view
union_hcode(data, 6) %>% simple_view
union_hcode(data, 4) %>% simple_view
union_hcode(data, 2) %>% simple_view
