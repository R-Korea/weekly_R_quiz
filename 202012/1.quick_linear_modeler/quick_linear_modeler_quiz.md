Q) 간단한 선형모델들을 빠르게 탐색해볼 수 있는 샤이니 앱을 만들어주세요!   

> 조건 :
  
- 사용자 컴퓨터에서 Train, Test data file 을 선택합니다 (csv, xlsx, xls 파일)    
- 파일을 로드하면 columns 탭에 해당 파일의 컬럼명, 컬럼타입을 테이블 형태로 표시해줍니다  
- Regression Type 라디오 버튼을 통해 선형모델의 종류를 선택합니다 (OLS, Ridge, Lasso)  
- Formula 부분에 관계식을 입력합니다 (y ~ x1 + I(x2^2) + x1*x3 등 R base formula 형식)  
- x-axis order column 에 x축 정렬 기준이 되는 컬럼을 선택합니다 (생략하는 경우 첫번째 컬럼 기준)    
- Fit Model 버튼을 누르면 선택한 조건들을 적용하여 모델을 적합합니다  
- chart 탭에는 실선은 실제값, 점선은 예측값, 막대바는 오차로 ggplot chart 를 그려줍니다 (Test RMSE도 표시)  
- coef 탭에는 계수명과 그 값을 테이블 형태로 표시해줍니다  
- Download 버튼을 누르면 model을 rds 파일로 다운로드 받습니다  
- model fitting 중 error가 발생할 경우, input$message_box를 통해 에러메세지를 표시하고 fitting 을 중단합니다  

---
  
![result_pic!](quick_linear_modeler_result.PNG) 
> 어플리케이션 영상 : `quick_linear_modeler_result.mp4` 참조

---
  
```{r}
library(readxl)
library(dplyr)
library(tidyr)
library(data.table)

library(glmnet)

library(ggplot2)
library(patchwork)

library(shiny)
library(shinydashboard)

rm(list=ls())

head <- dashboardHeader(disable=TRUE)
sidebar <- dashboardSidebar(disable=TRUE)

body <- dashboardBody(
  h3('Quick Linear Modeler'),
  fluidRow(
    tabBox(width=8, height='600px',
           tabPanel('columns', DT::dataTableOutput('columns', height='600px')),
           tabPanel('chart', plotOutput('chart', height='600px')),
           tabPanel('coef', DT::dataTableOutput('coef'))
    ),
    box(width=4, 
        fileInput("train_data", label="Train Data", accept = c('.csv','.xlsx','.xls')),
        fileInput("test_data", label="Test Data", accept = c('.csv','.xlsx','.xls')),
        radioButtons('reg_type', label='Regression Type', choices=c('OLS'='ols', 'Ridge'='ridge', 'Lasso'='lasso')),
        textInput('formula', label='Formula', value='', placeholder='y ~ x1 + x2:x3 + I(x4^2)'),
        textInput('x_axis_order_col', label='x-axis order column', value='', placeholder='x1'),
        actionButton('run', label='Fit Model'),
        downloadButton('download', label='Download'),
        h3(),
        textOutput('message_box')
    )
  ),
  tags$head(tags$style("#message_box{color: orange; font-weight: bold;}"))
)

ui <- dashboardPage(head, sidebar, body)

server <- function(input, output){

}

shinyApp(ui, server)
```
