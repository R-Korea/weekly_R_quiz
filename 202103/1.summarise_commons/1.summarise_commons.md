Q) 주어진 서울시 동 단위 행정구역 폴리곤을 구 단위로 묶으려합니다.  
이때 hcode의 공통되는 부분은 그대로, 다른 부분은 * 로 마스킹하여 다음과 같은 상위 행정구역 hcode 를 만들어주세요!  
  
> 행정동 경계 출처 : https://github.com/vuski/admdongkor

---
  
![result!](summarise_commons_result.PNG) 

---
  
```{r}
if(!require('devtools')) install.packages('devtools')
devtools::install_github("Curycu/valuemap")

library(valuemap)
library(dplyr)

rm(list=ls())

polygon <- readRDS('polygons.RDS')
```
