library(dplyr)
library(sf)
library(leaflet)

# devtools::install_github("obrl-soil/h3jsr")
library(h3jsr)

rm(list=ls())

data <- readRDS('points.RDS')

# ======================

# 1. draw exact points & lines
point.network <- function(df){
  
  df_to_point <- function(df){
    df %>%
      select(1, 2) %>%
      as.matrix %>%
      st_multipoint %>%
      st_sfc(crs=4326) %>%
      st_cast('POINT') %>%
      st_sf %>%
      mutate(idx = 1:n())
  }
  
  from.points <- data %>% select(from_lng, from_lat) %>% df_to_point
  to.points <- data %>% select(to_lng, to_lat) %>% df_to_point
  points.long <- rbind(from.points, to.points)
  
  lines <-
    points.long %>%
    group_by(idx) %>%
    summarise(count = n()) %>%
    mutate(class_name = sapply(geometry, function(x) paste0(class(x), collapse='/'))) %>%
    filter(class_name == 'XY/MULTIPOINT/sfg') %>%
    st_cast('LINESTRING')
  
  leaflet() %>%
    addTiles %>%
    addPolylines(data=lines, color='blue', weight=3, dashArray=6) %>%
    addCircles(data=points.long, fillColor='black', fillOpacity=1, opacity=0, radius=3)  
}

point.network(data)

# 2. draw h3 center points & lines
h3.network <- function(df, h3.res=11){
  
  df_to_point <- function(df){
    df %>%
      select(1, 2) %>%
      as.matrix %>%
      st_multipoint %>%
      st_sfc(crs=4326) %>%
      st_cast('POINT') %>%
      st_sf %>%
      mutate(idx = 1:n())
  }
  
  from.points <- data %>% select(from_lng, from_lat) %>% df_to_point
  to.points <- data %>% select(to_lng, to_lat) %>% df_to_point
  points.long <- rbind(from.points, to.points)
  
  h3.addrs <- 
    points.long %>%
    mutate(h3_addr = point_to_h3(.$geometry, res=h3.res)) %>%
    as.data.frame %>%
    select(-geometry) %>%
    arrange(idx, h3_addr)
  
  h3.border <-
    h3.addrs %>%
    distinct(h3_addr) %>%
    mutate(geometry = h3_to_polygon(h3_addr)) %>%
    st_as_sf
  
  node <-
    h3.addrs %>%  
    group_by(h3_addr) %>%
    summarise(node_count = length(unique(idx))) %>%
    mutate(geometry = h3_to_point(h3_addr)) %>%
    st_as_sf
  
  h3.sorted.long <- 
    h3.addrs %>%
    group_by(idx) %>%
    mutate(idx.order = 1, idx.order = cumsum(idx.order)) %>%
    ungroup
  
  h3.sorted.x <- h3.sorted.long %>% filter(idx.order == 1) %>% transmute(idx, h3_addr_x = h3_addr)
  h3.sorted.y <- h3.sorted.long %>% filter(idx.order == 2) %>% transmute(idx, h3_addr_y = h3_addr)
  
  h3.sorted <- 
    h3.sorted.x %>% 
    inner_join(h3.sorted.y, by='idx') %>% 
    group_by(h3_addr_x, h3_addr_y) %>%
    mutate(idx.order = 1, idx.order = cumsum(idx.order)) %>%
    ungroup
  
  edge.count <-
    h3.sorted %>%
    group_by(h3_addr_x, h3_addr_y) %>%
    summarise(edge_count = length(unique(idx)))    
  
  idx.filter <-
    h3.sorted %>% 
    filter(idx.order == 1) %>% 
    .$idx
  
  edge <-
    h3.addrs %>%
    filter(idx %in% idx.filter) %>%
    mutate(geometry = h3_to_point(h3_addr)) %>%
    st_sf %>%
    group_by(idx) %>%
    summarise(count = n()) %>%
    mutate(class_name = sapply(geometry, function(x) paste0(class(x), collapse='/'))) %>%
    filter(class_name == 'XY/MULTIPOINT/sfg') %>%
    select(-count, -class_name) %>%
    st_cast('LINESTRING') %>%
    inner_join(h3.sorted, by='idx') %>%
    inner_join(edge.count, by=c('h3_addr_x','h3_addr_y')) %>%
    select(-idx.order)
  
  list(node=node, edge=edge, h3.border=h3.border)
}

network <- h3.network(data)

node <- network$node
edge <- network$edge
h3.border <- network$h3.border

node.weight <- 3
edge.weight <- 3 
node.filter <- 1 
edge.filter <- 1

leaflet() %>%
  addTiles %>%
  addPolygons(data=h3.border, color='gray', fillOpacity=0, opacity=.5, weight=1.5) %>%
  addPolylines(data=edge %>% filter(edge_count >= edge.filter), color='blue', dashArray=6, weight=~edge_count*node.weight) %>%
  addCircles(data=node %>% filter(node_count >= node.filter), fillColor='black', fillOpacity=.5, opacity=0, radius=~node_count*node.weight)

