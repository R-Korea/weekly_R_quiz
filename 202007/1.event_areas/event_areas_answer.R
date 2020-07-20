library(dplyr)
library(sf)
library(leaflet)

rm(list=ls())

# all geospatial objects are made by 'geodrawr' package
# install.packages('geodrawr')

base_crs <- '+proj=longlat +datum=WGS84'
base_datetime_format <- '%Y-%m-%d %H:%M:%S'

date_to_time <- function(date, time) {
  paste(date, time) %>%
    strptime(format=base_datetime_format, tz='UTC') %>%
    as.POSIXct
}

init_at <- date_to_time('2020-05-15', '00:00:00')

event_area_01 <- readRDS('event_area_01.rds') %>% st_multipolygon %>% st_sfc
event_area_02 <- readRDS('event_area_02.rds') %>% st_multipolygon %>% st_sfc
event_area_03 <- readRDS('event_area_03.rds') %>% st_multipolygon %>% st_sfc

areas <- 
  data.frame(
    apply_at = init_at + c(0 + 1*60*60, 0 + 10*60*60, 0 + 19*60*60),
    geometry = c(event_area_01, event_area_02, event_area_03))

areas[1,1] <- NA
areas <-
  areas %>%
  transmute(
    apply_at, 
    end_at = lead(apply_at, 1) - 1,
    apply_at = coalesce(apply_at, date_to_time('0001-01-01','00:00:00')),
    end_at = coalesce(end_at, date_to_time('9999-12-31','23:59:59')),
    geometry) %>%
  st_sf(crs=base_crs)

areas

set.seed(20200712)

points <- 
  readRDS('events.rds') %>% 
  st_sf(crs=base_crs) %>% 
  transmute(occur_at = init_at + 24*60*sample(x=0:60, size=n(), rep=TRUE)) %>%
  arrange(occur_at)

points

# ========================

daily_matched_points <- function(areas, points, from_date, to_date){
  
  from_date <- as.Date(from_date)
  to_date <- as.Date(to_date)
  target_dates <- from_date + seq(0, as.integer(to_date - from_date)) 
  target_dates_str <- target_dates %>% format('%Y-%m-%d')
  
  area_point_match <- function(area, points){
    suppressMessages({
      matched <-
        points %>%
        st_intersects(area) %>%
        unlist %>%
        sum
      
      total <-
        points %>%
        st_intersects(area) %>%
        length
    })
    
    list(matched=matched, total=total)
  }
  
  date_to_time <- function(date, time) {
    base_datetime_format <- '%Y-%m-%d %H:%M:%S'
    paste(date, time) %>%
      strptime(format=base_datetime_format, tz='UTC') %>%
      as.POSIXct
  }
  
  df <- data.frame()
  
  for(target_day in target_dates_str){
    target_day_from <- date_to_time(target_day,'00:00:00')
    target_day_to <- date_to_time(target_day,'23:59:59')
    
    areas_of_target_day <-
      areas %>%
      filter(!(end_at < target_day_from | target_day_to < apply_at))
    
    for(i in 1:nrow(areas_of_target_day)){
      at <- 
        areas_of_target_day[i,]
      
      et <-
        points %>%
        filter(
          as.Date(target_day) == as.Date(occur_at) &
            at$apply_at <= occur_at & 
            occur_at <= at$end_at)
      
      rs <- area_point_match(at, et)
      
      df <- {
        new_df <-
          data.frame(
            date = as.Date(target_day, origin='1970-01-01'), 
            matched_event = rs[['matched']], 
            total_event = rs[['total']],
            geometry = at$geometry)
        
        rbind(df, new_df)
      }
    }
  }
  
  df
}

# ========================

(result <- daily_matched_points(areas, points, '2020-05-13', '2020-05-17'))

show_date = '2020-05-16'

leaflet() %>%
  addTiles %>%
  addPolygons(data=result %>% filter(date == show_date) %>% st_sf(crs=base_crs)) %>%
  addCircles(data=points %>% filter(as.Date(occur_at) == as.Date(show_date)), color='red')

result %>% filter(date == show_date)
