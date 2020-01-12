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

result <-
  polygons %>%
  st_intersection(points$geometry) %>% 
  group_by(adm_cd, adm_nm) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  ungroup %>%
  as.data.frame %>%
  select(-geometry)

polygons %>%
  inner_join(result %>% select(adm_cd, count), by='adm_cd') %>%
  mapview(zcol='count', map.type='CartoDB.Positron', alpha.region=.5)
