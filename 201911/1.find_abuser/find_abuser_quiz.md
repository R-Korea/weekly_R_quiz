Q) 어뷰저를 찾기 위한 블랙리스트 함수를 작성해주세요

bike_user_history.csv : 자전거 이용이력  
not_found.csv : 찾지못함 신고이력  

blacklist :   
  특정 자전거에 찾지못함 신고가 연속 N회 이상 들어온 이후 (중간에 자전거 이용이력 없이 N회 연속 신고)  
  자전거를 이용한 사람이 신고가 들어오기 전에 이용한 사람과 동일한 경우 어뷰저로 확인하는 함수  

```{r, message=FALSE, warning=FALSE}
library(dplyr)
library(data.table)

rm(list=ls())

bike <- 
  fread('bike_use_history.csv') %>%
  mutate(time_at = as.POSIXct(time_at, format="%Y.%m.%d_%H:%M:%S")) %>%
  mutate(status='bike_use')

not.found <-
  fread('not_found.csv') %>%
  mutate(time_at = as.POSIXct(time_at, format="%Y.%m.%d_%H:%M:%S")) %>%
  mutate(user_id = NA, status='not_found')

blacklist <- function(bike, not.found, not.found.limit){
  
}
```

결과는 다음과 같습니다  

연속 1회 조건 
> blacklist(bike, not.found, 1) %>% View   
![target!](find_abuser_1.PNG)

연속 5회 조건 
> blacklist(bike, not.found, 5) %>% View  
![target!](find_abuser_5.PNG)
