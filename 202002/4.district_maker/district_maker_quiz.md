Q) 임의의 구역을 그리고 저장할 수 있는 샤이니 앱을 작성해주세요!     
  
> 조건 :
  
- 맵을 클릭하여 구역의 꼭지점을 지정합니다  
- '구역 생성' 버튼을 누르면 첫 지점과 끝 지점을 연결하여 구역을 생성합니다  
- '지우기' 버튼을 누르면 맵에 그려진 모든 구역이 삭제됩니다  
- '저장' 버튼을 누르면 맵에 그려진 모든 구역이 저장됩니다  
- 파일명은 Save File Name 글상자를 참조합니다  
- 저장된 파일 경로를 콘솔에 출력해줍니다  

---
  
![result_pic!](district_maker_result.PNG) 
> 어플리케이션 영상 : `district_maker_result.mp4` 참조 

---

```{r}
library(dplyr)
library(sf)
library(leaflet)
library(shiny)

rm(list=ls())

ui <- fluidPage(
  h1('District Maker'),
  fluidRow(
    column(8, leafletOutput('map', width='800px', height='600px')),
    column(3, 
           textInput('save_file_name', label=h3('Save File Name'), value = 'districts.RDS'),
           actionButton('make_polygon', '구역 생성'),
           actionButton('clear', '지우기'),
           actionButton('save_polygons', '저장')
    )
  )
)

server <- function(input, output){
  
}

shinyApp(ui, server)
```