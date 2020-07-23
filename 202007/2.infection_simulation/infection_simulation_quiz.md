Q) 사회 구성원들의 움직임에 따른 감염 시뮬레이션을 만들어주세요!  
- 시뮬레이션 계산 입력값으로 다음 6가지 값을 받습니다
  - 전체 인원수
  - 초기 감염자 비중
  - 감염 반경
  - 구성원 이동속도
  - 구역 길이
  - 시간 길이

---

![result_pic!](infection_simulation_result.PNG) 
> 어플리케이션 영상 : `infection_simulation_result.mp4` 참조

---

```
library(dplyr)
library(sf)
library(ggplot2)
library(shiny)
library(shinydashboard)

rm(list=ls())

head <- dashboardHeader(disable=TRUE)
sidebar <- dashboardSidebar(disable=TRUE)

body <- dashboardBody(
  h3('감염 시뮬레이션'),
  fluidRow(
    column(width=8,
           plotOutput('view', width='100%', height='800px')
    ),
    box(width=4, 
        sliderInput('n', label='전체 인원', min=2, max=50, value=50, step=1),
        sliderInput('infected.rate', label='초기 감염자 비중', min=0, max=1, value=.3, step=.01),
        sliderInput('danger.distance', label='감염 반경', min=1, max=10, value=2, step=1),
        sliderInput('speed', label='구성원 이동속도', min=1, max=10, value=1, step=1),
        sliderInput('area.length', label='구역 길이', min=1, max=100, value=30, step=1),
        sliderInput('time.length', label='시간 길이', min=1, max=100, value=50, step=1),
        actionButton('run', label='시뮬레이션 계산'),
        sliderInput('selected_time', label='시간대 선택', min=1, max=100, value=1, step=1, animate=TRUE)
    )
  )
)

ui <- dashboardPage(head, sidebar, body)

server <- function(input, output){

}

shinyApp(ui, server)
```