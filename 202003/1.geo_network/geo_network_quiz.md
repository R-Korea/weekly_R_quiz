Q) 지리정보를 기반으로 네트워크를 그려주는 함수 point.network 와 h3.network 를 작성해주세요!  
  
> 조건 :
  
- point.network는 event point를 그대로 node 삼아 network를 그립니다  
- h3.network는 event point들을 h3 hexagon으로 변환 후 그 중심점을 node로 삼아 network를 그립니다  
- h3.network는 집계된 event count를 기반으로 node의 크기 및 edge의 굵기를 지정합니다  
- h3.network에서 edge의 event count 집계는 (node A -> node B) == (node B -> node A) 임을 주의하세요!   
- h3.network의 res는 h3 resolution을 조절합니다  
- h3.network의 node.weight, edge.weight는 event count 집계에 곱해져 크기 및 굵기를 보기 좋게끔 조절합니다  

---
  
![result_pic!](geo_network_result.PNG) 

---

```{r}
library(dplyr)
library(sf)
library(leaflet)

# devtools::install_github("obrl-soil/h3jsr")
library(h3jsr)

rm(list=ls())

data <- readRDS('points.RDS')

# ======================

# 1. draw nodes & edges
point.network <- function(df){

}

point.network(data)

# 2. draw h3 center points as nodes & edges
h3.network <- function(df, res=11, node.weight=3, edge.weight=3){

}

h3.network(data)
```
