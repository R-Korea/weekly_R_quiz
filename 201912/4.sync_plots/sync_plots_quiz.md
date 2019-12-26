Q) server 함수를 완성하여 plot1에서 드래그(=brush)한 데이터들을 plot2에 첨부그림과 같이 강조하는 shiny app을 만들어주세요!

![result!](sync_plots_result.PNG) 

```{r}
library(shiny)
library(ggplot2)
library(dplyr)

# reference : 
# https://shiny.rstudio.com/gallery/plot-interaction-basic.html
# https://shiny.rstudio.com/gallery/plot-interaction-zoom.html

data <- mtcars %>% mutate(id = 1:n())

my_theme <- 
  theme_bw() + 
  theme(
    legend.position='none',
    panel.grid = element_blank()) 

ui <- fluidPage(
  fluidRow(
    mainPanel(
      h3('How to Sync Plots'),
      code('hint : reactiveValues, observe')
    )
  ),
  fluidRow(
    column(6, plotOutput('plot1', brush=brushOpts(id='brush'))),
    column(6, plotOutput('plot2'))
  )
)

server <- function(input, output) {

}

shinyApp(ui, server)
```
