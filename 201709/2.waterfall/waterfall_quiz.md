Q) 주어진 데이터를 이용해서 차트를 그려주세요 :)  

![target!](waterfall_result.PNG)

```{r, message=FALSE, warning=FALSE, include=FALSE}
library(dplyr)
library(ggplot2)

raw.data <- 
  data.frame(
    year=2009:2017, 
    value=c(100,110,140,160,90,30,50,150,220))
```
