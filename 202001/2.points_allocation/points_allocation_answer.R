library(sf)
library(dplyr)
library(leaflet)
library(mapview)

rm(list=ls())

points <- readRDS('points.RDS')
polygons <- readRDS('polygons.RDS')

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data=polygons, color='black', weight=1, fillColor='gold', fillOpacity=.2) %>%
  addCircles(data=points, color=NA, weight=5, fillColor='blue', fillOpacity=1)

poly.sum <-
  polygons %>%
  st_intersection(points$geometry) %>% 
  group_by(adm_cd, adm_nm) %>%
  summarise(counts = n()) %>%
  arrange(desc(counts)) %>%
  ungroup %>%
  as.data.frame %>%
  select(-geometry)

view.data <-
  polygons %>%
  inner_join(poly.sum %>% select(adm_cd, counts), by='adm_cd')

mapview(view.data, zcol='counts', map.type='CartoDB.Positron', alpha.region=.5)
