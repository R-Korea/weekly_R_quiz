library(dplyr)
library(sf)
library(h3jsr)
library(leaflet)

rm(list=ls())

# hangjeongdong full detail polygons
hjd <- readRDS('hangjeongdong_20200401.RDS')

# input parameters
h3.res <- 7

buffer.meter <-
  h3_info_table %>% 
  filter(h3_resolution == h3.res) %>% 
  .$avg_cendist_m * 2.5

# cover (not fill) input polygon with h3 hexagons :
#   extend input polygon with buffer & polyfill that extended polygon
# arguments :
#   h3_res : h3 hexagon's resolution
#   buffer_meter : buffer for input polygon (unit : meter)
polycover <- function(polygon, h3_res, buffer_meter){
  polygon %>%
    st_transform(crs=5181) %>%
    st_buffer(dist=buffer_meter) %>%
    st_transform(crs=4326) %>%
    polyfill(h3_res)
}

# hangjeongdong upper level polygons
hjd.lv <- 
  hjd %>%
  group_by(lv1) %>%
  summarise(count = sum(1)) %>%
  ungroup

# h3 polygons : polycovered hangjeongdong upper level polygons
hjd.lv.h3 <- data.frame()

for(i in 1:nrow(hjd.lv)){
  h3_addr <-
    hjd.lv[i,] %>%
    polycover(h3_res=h3.res, buffer_meter=buffer.meter) %>%
    unlist
  
  print(paste(i, '/', nrow(hjd.lv), ': ', hjd.lv[i,]$lv1, sep=''))
  
  res <-
    h3_addr %>%
    h3_to_polygon() %>%
    data.frame(
      name = paste(hjd.lv[i,]$lv1),
      h3_addr = h3_addr,
      geometry = .)
  
  hjd.lv.h3 <- 
    rbind(hjd.lv.h3, res)
}

hjd.lv.h3 <- hjd.lv.h3 %>% st_sf

# h3 addresses : polycovered hangjeongdong full detail polygons
hjd.h3.addr <- data.frame()
row.count <- 0

for(i in 1:nrow(hjd.lv)){
  
  (lv_region_name <- hjd.lv[i,]$lv1)
  
  base.h3 <- 
    hjd.lv.h3 %>% 
    filter(name == lv_region_name)
  
  for(j in 1:nrow(hjd %>% filter(lv1 == lv_region_name))){
    
    row.count = row.count + 1
    
    target.hjd <- 
      hjd %>% 
      filter(lv1 == lv_region_name) %>% 
      .[j,]
    
    print(paste(row.count, '/', nrow(hjd), ': ', target.hjd$adm_nm, sep=''))
    
    suppressMessages({
      target.h3 <-
        base.h3 %>%
        mutate(
          is_target = st_intersects(geometry, target.hjd, sparse=FALSE),
          h3_addr = base.h3$h3_addr,
          hcode = target.hjd$adm_cd2,
          region_name = target.hjd$adm_nm
        ) %>%
        filter(is_target) %>%
        as.data.frame %>%
        select(hcode, region_name, h3_addr) 
    })
    
    hjd.h3.addr <- rbind(hjd.h3.addr, target.h3) 
  }
}

saveRDS(hjd.h3.addr, 'hjd_h3_addr.RDS')
hjd.h3.addr <- readRDS('hjd_h3_addr.RDS')

hjd.h3 <-
  hjd.h3.addr %>%
  mutate(geometry = h3_to_polygon(hjd.h3.addr$h3_addr)) %>%
  st_sf

leaflet() %>%
  addProviderTiles(provider=providers$CartoDB.Positron) %>%
  addPolygons(data=hjd.h3, weight=1, fillOpacity=.2, opacity=0, color='blue') %>%
  addPolygons(data=hjd, weight=1, fillOpacity=0, color='black')
