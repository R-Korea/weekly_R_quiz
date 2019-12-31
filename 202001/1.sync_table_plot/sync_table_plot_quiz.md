Q) 첨부그림과 같이 datatable과 leaflet plot을 연동한 shiny app을 만들어주세요!

> 조건 :
- table의 3, 7, 9, 10번 row는 처음부터 선택되어 있습니다
- table의 row를 선택하면 plot의 해당하는 marker가 선명해집니다 (= 선택하지 않은 marker는 투명합니다)
- table의 row display는 6줄로 설정되어 있습니다 (= show 6 entries)
- leaflet tile은 Stamen.Toner로 설정합니다

---

![result!](sync_table_plot_result.PNG) 

---

```{r}
library(dplyr)
library(data.table)
library(leaflet)
library(DT)
library(shiny)

# reference : 
# https://yihui.shinyapps.io/DT-rows/
# https://rstudio.github.io/DT/shiny.html
# https://rstudio.github.io/leaflet/basemaps.html

input.gist <- 
  'https://gist.githubusercontent.com/Curycu/1b913d73e16c9811c75efebe20cebf57/raw/a6e3b0ead49ad19f0e40e59c36ad8021fecff877/sync_table_plot.csv'

data <-
  fread(input.gist, encoding='UTF-8') %>%
  mutate(id = 1:n(), selected = FALSE)

ui <- fluidPage(
  h1('Sync Table & Plot'),
  
  fluidRow(
    column(6, DT::dataTableOutput('t1')),
    column(6, leafletOutput('m1', height = 500))
  )
)

server <- function(input, output){

}

shinyApp(ui, server)
```
