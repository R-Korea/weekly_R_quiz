Q) 이벤트 구역 내에서 발생한 이벤트 수를 집계해주는 함수 daily_matched_events 를 구현해주세요!  
- 입력값으로 다음 4가지 내역을 받습니다 : 이벤트 구역, 이벤트 발생이력, 집계시작일, 집계종료일  
- 이벤트 구역은 시간에 따라 변화하였으며 그 이력은 event_areas 에 기록되었습니다  
- 이벤트 발생이력은 events 에 기록되었습니다  
- 집계시작일, 집계종료일은 '%Y-%m-%d' format의 character 로 받습니다  

```{r, message=FALSE, warning=FALSE}
library(dplyr)
library(sf)
library(leaflet)

rm(list=ls())

# all geospatial objects are made by 'geodrawr' package
# install.packages('geodrawr')

base_crs <- '+proj=longlat +datum=WGS84'

event_area_01 <- readRDS('event_area_01.rds') %>% st_multipolygon %>% st_sfc
event_area_02 <- readRDS('event_area_02.rds') %>% st_multipolygon %>% st_sfc
event_area_03 <- readRDS('event_area_03.rds') %>% st_multipolygon %>% st_sfc

event_areas <- 
  data.frame(
    apply_at = as.Date('2020-04-01') + c(0, 45, 70),
    geometry = c(event_area_01, event_area_02, event_area_03)
  ) %>%
  st_sf(crs=base_crs)

event_areas[1,1] <- NA
event_areas
```
![](event_areas_result_01.PNG)  

```{r, message=FALSE, warning=FALSE}
set.seed(20200712)

events <- 
  readRDS('events.rds') %>% 
  st_sf(crs=base_crs) %>% 
  transmute(occur_at = as.Date('2020-04-01') + sample(x=0:70, size=n(), rep=TRUE)) %>%
  arrange(occur_at)

events
```
![](event_areas_result_02.PNG)  

```
daily_matched_events <- function(event_areas, events, from_date, to_date){

}

result <- daily_matched_events(event_areas, events, '2020-05-01', '2020-06-30')

show_date = '2020-05-22'

leaflet() %>%
  addTiles %>%
  addPolygons(data=result %>% filter(date == show_date) %>% st_sf(crs=base_crs)) %>%
  addCircles(data=events %>% filter(occur_at == as.Date(show_date)), color='red')
```
![](event_areas_result_03.PNG)  

```{r}
result %>% filter(date == show_date)
```
![](event_areas_result_04.PNG)  