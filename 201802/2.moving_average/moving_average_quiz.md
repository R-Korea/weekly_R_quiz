Q) 주어진 데이터를 이용하여 3개월 이동평균 차트를 그려주세요!  

```{r, message=FALSE, warning=FALSE, include=FALSE}
library(ggplot2)
library(scales)

rm(list=ls())

set.seed(20180225)

n <- 36

profit <- 
  ts(
    data=floor(100 * (sort(rnorm(n, 0, 1)) + rnorm(n, 0, .8))), 
    start=c(2018, 1), 
    frequency=12)
```

![target!](moving_average_result.PNG)
