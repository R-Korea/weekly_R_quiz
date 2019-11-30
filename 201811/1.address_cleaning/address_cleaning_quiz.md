Q) 주어진 데이터를 행정단위 '동' 상위 행정단위만 남겨주세요...!  

```{r, message=FALSE, warning=FALSE}
library(dplyr)
library(stringr)

rm(list=ls())

data <-
  data.frame(
    address_1 = c(
      '경기도 수원시 장안구 파장1동 삼호빌라 B동',
      '수원시 정자2동 백설마을 주공아파트 571동 103-1023',
      '경기도 정자동 현준맨션 2동',
      '경기도 장안구 정자1동 e편한 맨션 310-7번지',
      '서울시 동작구 사당1동',
      '서울시 문래동 1가 200-1',
      '경상북도 안동시 안기동 20-1 ',
      '서문래2동 '), 
    stringsAsFactors=FALSE)
```

![target!](address_cleaning_result.PNG)
