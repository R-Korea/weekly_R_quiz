Q) starwars 시리즈들의 유사도를 등장인물들의 자카드 유사도를 통해 첨부 차트와 같이 표현해주세요...!  

jaccard similarity : https://ko.wikipedia.org/wiki/%EC%9E%90%EC%B9%B4%EB%93%9C_%EC%A7%80%EC%88%98  

```{r, message=FALSE, warning=FALSE, include=FALSE}
library(dplyr)
library(data.table)
library(ggplot2)
library(scales)

rm(list=ls())

raw.data <- 
  starwars %>% 
  select(name, films)
```

![target!](movie_similarity_result.PNG)
