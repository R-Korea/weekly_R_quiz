Q) 주어진 행정동 지역과 H3 polygon을 맵핑해주세요!  
  
> 조건 :
  
- 행정동은 시/도 레벨인 level 1 에서 읍/면/동 레벨인 level 3 까지 존재합니다  
- 행정동 level 3 수준에서 모든 행정동 단위에 대해 H3 polygon 을 맵핑하는 것이 목표입니다   
- 반드시 모든 행정동 단위의 경계가 온전히 H3 polygon 으로 감싸여야합니다  
- 따라서 행정동 단위의 경계 부분의 H3 polygon 들은 첨부 스크린샷처럼 중복으로 맵핑되게 됩니다  
- H3 polygon 의 해상도는 level 7 을 권장하며 다른 해상도로도 쉽게 조절할 수 있다면 더욱 좋습니다  
  
> 행정동 경계 출처 : https://github.com/vuski/admdongkor  
  
---
  
![result_pic!](hcode_h3_mapping_result.PNG) 

---

```{r}
library(dplyr)
library(sf)
library(leaflet)

# devtools::install_github("obrl-soil/h3jsr")
library(h3jsr)

rm(list=ls())

# hangjeongdong full detail polygons
hjd <- readRDS('hangjeongdong_20200401.RDS')
```
