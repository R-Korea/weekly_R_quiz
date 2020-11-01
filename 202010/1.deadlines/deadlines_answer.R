library(sf)
# library(geodrawr) # to make example center point & lines coordinates
library(leaflet) # to visualize point, circle (for radius), lines

rm(list=ls())

# input data
lat <- 127.0384
lon <- 37.26482

radius <- 21

line.list <- list(
  matrix(c(127.0384, 37.26496, 127.0385, 37.26471), 2, byrow=TRUE),
  matrix(c(127.0383, 37.26475, 127.0385, 37.26496), 2, byrow=TRUE),
  matrix(c(127.0387, 37.26476, 127.0385, 37.26507), 2, byrow=TRUE),
  matrix(c(127.0381, 37.26487, 127.0382, 37.26455), 2, byrow=TRUE),
  matrix(c(127.0388, 37.26475, 127.038, 37.26489), 2, byrow=TRUE)
)

# ============= visual check ===============

wgs <- 4326
wtm <- 5181

center <- 
  c(lat, lon) %>% 
  st_point %>% 
  st_sfc(crs=wgs)

circle <-
  center %>%
  st_sfc(crs=wgs) %>%
  st_transform(crs=wtm) %>%
  st_buffer(dist=radius) %>%
  st_transform(wgs)

lines <- 
  line.list %>% 
  lapply(st_linestring) %>% 
  st_sfc(crs=wgs)

leaflet() %>%
  addTiles %>%
  addPolygons(data=circle, weight=2, fillOpacity=0, color='red', dashArray=5) %>%
  addPolylines(data=lines, weight=2) %>%
  addCircles(data=center, weight=1, radius=1, fillOpacity=1, color='red')

# ============= function check ===============

dead.line.check <- function(lat, lon, radius, line.list){
  wgs <- 4326
  wtm <- 5181
  
  center <- 
    c(lat, lon) %>% 
    st_point %>% 
    st_sfc(crs=wgs)
  
  circle <-
    center %>%
    st_sfc(crs=wgs) %>%
    st_transform(crs=wtm) %>%
    st_buffer(dist=radius) %>%
    st_transform(wgs)
  
  lines <- 
    line.list %>% 
    lapply(st_linestring) %>% 
    st_sfc(crs=wgs)
  
  lines %>% 
    st_intersects(circle)
}

dead.line.check(lat, lon, radius, line.list)
