Q) 주어진 1단계 깊이 json 컬럼을 풀어 data.frame 으로 이어붙여주는 함수 unnest_json_col 함수를 만들어주세요!  

---

```{r}
library(dplyr)
library(tibble)
library(rjson)

rm(list=ls())

data = tribble(
  ~session, ~json,
  'A', '{"Unit":["Marine","Medic","Tank"],"Action":"Move"}',
  'B', '{"Unit":["Marine","Medic","Tank"],"Action":"Attack","Target":"Zealot"}',
  'C', '{"Unit":["Medic"],"Action":"Heal","Target":["Marine","Ghost","Marine"]}',
  'D', '{"Unit":["SCV"],"Action":[],"Target":["Tank"]}'
) %>% as.data.frame

unnest_json_col = function(df, col){

}

unnest_json_col(data, 2)

# session    key  value
#       A   Unit Marine
#       A   Unit  Medic
#       A   Unit   Tank
#       A Action   Move
#       B   Unit Marine
#       B   Unit  Medic
#       B   Unit   Tank
#       B Action Attack
#       B Target Zealot
#       C   Unit  Medic
#       C Action   Heal
#       C Target Marine
#       C Target  Ghost
#       C Target Marine
#       D   Unit    SCV
#       D Target   Tank
```