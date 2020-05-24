library(data.table)
library(dplyr)
library(tidyr)
library(waffle)
library(showtext)
library(shiny)
library(shinydashboard)

font_add_google('Nanum Pen Script', 'pen')
showtext_auto()

head <- dashboardHeader(disable=TRUE)
sidebar <- dashboardSidebar(disable=TRUE)

body <- dashboardBody(
  h3("Let's Waffle"),
  fluidRow(
    tabBox(width=8, 
      tabPanel('plot', plotOutput('plot', height='600px')),
      tabPanel('table', DT::dataTableOutput('table'))
    ),
    box(width=4,
      h6('연도'),
      selectInput('year', label=NULL, selected = 2019, choices = 
        list(`1990년대` = list(1992,1993,1994,1995,1996,1997,1998,1999), 
             `2000년대` = list(2000,2001,2002,2003,2004,2005,2006,2007,2008,2009),
             `2010년대` = list(2010,2011,2012,2013,2014,2015,2016,2017,2018,2019))),
      downloadButton('download', 'Download')
    )
  )
)

ui <- dashboardPage(head, sidebar, body)

server <- function(input, output){
  
  raw.demo <- fread('demo_1992_2019.csv', header=TRUE)
  
  colnames(raw.demo) <- c('region', colnames(raw.demo)[-1])
  demo <- raw.demo[2:nrow(raw.demo), ] 
  
  odd <- function(x) x[x %% 2 == 1]
  even <- function(x) x[x %% 2 == 0]
  
  male <- 
    demo %>% 
    as.data.frame %>% 
    .[, c(1, even(2:ncol(demo)))] %>%
    gather(key='year', value='count', -region) %>%
    mutate(
      year = year %>% as.integer,
      count = ifelse(count == '-', '0', count) %>% as.integer)
  
  female <- 
    demo %>% 
    as.data.frame %>% 
    .[, c(1, odd(2:ncol(demo)))] %>%
    gather(key='year', value='count', -region) %>%
    mutate(
      year = year %>% as.integer,
      count = ifelse(count == '-', '0', count) %>% as.integer)
  
  data <-
    rbind(
      male %>% mutate(gender = '남성'),
      female %>% mutate(gender = '여성'))
  
  output$plot <- renderPlot({
    data %>%
      filter(year == input$year) %>%
      filter(count > 0) %>%
      ggplot(aes(fill=gender, values=count/10^5)) +
      geom_waffle(colour='white', size=0, flip=TRUE, show.legend=TRUE) +
      facet_wrap(~ region, ncol=5) +
      theme_bw(base_family = 'pen') +
      theme(
        axis.ticks = element_blank(), 
        axis.text = element_blank(), 
        panel.grid = element_blank(),
        strip.text = element_text(size=15),
        legend.text = element_text(size=15)) + 
      scale_fill_manual(values=c('blue','red')) +
      labs(fill='')
  })
  
  output$table <- DT::renderDataTable(
    data %>%
      filter(year == input$year) %>%
      filter(count > 0) %>%
      select(year, region, gender, count) %>%
      arrange(year, region, gender),
    rownames=FALSE,
    options=list(pageLength=15)
  )
  
  output$download <- downloadHandler(
    filename = function() {
      paste('demo-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(data, con)
    }
  )
}

shinyApp(ui, server)
