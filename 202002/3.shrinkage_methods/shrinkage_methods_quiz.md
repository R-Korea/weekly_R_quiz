Q)  

주어진 formula 와 data 를 가공해 다음과 같은 차트를 그릴 수 있도록 코드를 작성해주세요!  

OLS : Ordinary Least Squares  
Ridge : Ridge Regression  
Lasso : Lasso Regression  

좌상단 차트는 각 모델의 계수값을 시각화하고 있으며  

나머지 차트들은 다음과 같습니다  

Line Graph 의 경우...  

실선은 실제값  
점선은 모델의 예측값  

Bar Graph 는 실제값과 예측값 간의 차이입니다 (= 실제값 - 예측값)  
  
---
  
![result!](shrinkage_methods_result.PNG) 

---
  
```{r}
library(dplyr)
library(glmnet)
library(ggplot2)
library(scales)
library(gridExtra)
library(tidyr)

rm(list=ls())

formula <- mpg ~ .

data <- 
  mtcars %>% 
  filter(complete.cases(.)) %>%
  mutate(idx = 1:n())

train.idx <- 
  1:(nrow(data)*2/3)
```
