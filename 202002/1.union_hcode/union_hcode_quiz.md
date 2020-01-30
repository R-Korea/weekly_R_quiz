Q) 주어진 data의 hcode 앞 N자리(=digit)를 key로 삼아 polygon들을 합쳐주는 함수 union_hcode를 완성해주세요! 

---
  
![result!](union_hcode_result.PNG) 

---
  
```{r}
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

}

union_hcode(data) %>% simple_view
union_hcode(data, 6) %>% simple_view
union_hcode(data, 4) %>% simple_view
union_hcode(data, 2) %>% simple_view
```
