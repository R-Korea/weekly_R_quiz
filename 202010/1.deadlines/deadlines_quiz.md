Q) 주어진 위경도 (lat, lon) 좌표 및 반경 (radius, meter 단위) 안쪽에 위치하는 선들을 체크하는 함수를 만들어주세요!

![result_pic!](deadlines_result.PNG)  
  
```{r}
library(sf)
# library(geodrawr) # to make example center point & lines coordinates
# library(leaflet) # to visualize point, circle (for radius), lines

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

dead.line.check(lat, lon, radius, line.list)
```

이 [페이스북_게시물](https://www.facebook.com/groups/krstudy/permalink/1738365539671044)을 보고 만든 퀴즈입니다!  
