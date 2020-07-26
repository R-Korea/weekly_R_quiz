library(dplyr)
library(sf)
library(ggplot2)
library(shiny)
library(shinydashboard)

rm(list=ls())

head <- dashboardHeader(disable=TRUE)
sidebar <- dashboardSidebar(disable=TRUE)

body <- dashboardBody(
  h3('사회 감염 시뮬레이션'),
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

# test
# n = 500
# area.length = 30
# infected.rate = .3
# danger.distance = 2
# speed = 1
# area.length = 30
# time.length = 10
# data = infection.simulation(n, infected.rate, danger.distance, speed, area.length, time.length)
# plot.list = make.ggplot(data)

server <- function(input, output){
  
  # util functions ============
  
  initial.state <- function(n, area.length, infected.rate){
    x <- sample(1:area.length, n, rep=TRUE)
    y <- sample(1:area.length, n, rep=TRUE)
    s <- sample(c(FALSE, TRUE), n, replace=TRUE, prob=c(1 - infected.rate, infected.rate))
    data.frame(id=1:n, x, y, is.danger=s)
  }
  
  make.danger.zone <- function(danger.points, danger.distance){
    danger.points %>%
      st_buffer(dist=danger.distance) %>%
      st_union()
  }
  
  df.to.points <- function(df){
    g <-
      df %>%
      select(x, y) %>%
      as.matrix %>%
      st_multipoint %>%
      st_sfc %>%
      st_cast('POINT')
    
    data.frame(df, geometry=g) %>% st_sf
  }
  
  check.victims <- function(danger.zone, safe.points){
    is.victim <-
      safe.points %>%
      st_intersects(danger.zone, sparse=FALSE)
    
    safe.points %>%
      mutate(is.danger = is.victim)
  }
  
  state.check <- function(df, danger.distance){
    safe.points_ <- df %>% filter(!is.danger)
    danger.points_ <- df %>% filter(is.danger) 
    
    if(nrow(safe.points_) == 0 | nrow(danger.points_) == 0){
      df
    }else{
      safe.points <- safe.points_ %>% df.to.points
      danger.points <- danger.points_ %>% df.to.points
      danger.zone <- make.danger.zone(danger.points, danger.distance)
      infection.checked.safes <- check.victims(danger.zone, safe.points)
      
      rbind(infection.checked.safes, danger.points) %>%
        as.data.frame %>%
        select(-geometry)
    }
  }
  
  move <- function(x, speed){
    abs(x + rnorm(length(x), sd=speed))
  }
  
  next.location <- function(df, speed){
    data.frame(id=df$id, x=move(df$x, speed), y=move(df$y, speed), is.danger=df$is.danger)
  }
  
  infection.simulation <- function(n, infected.rate, danger.distance, speed, area.length, time.length){
    history <- data.frame()
    danger.zones <- list()
    init <- initial.state(n, area.length, infected.rate) 
    
    for(t in 1:time.length){
      danger.points_ <- init %>% filter(is.danger) %>% df.to.points
      danger.zone <- make.danger.zone(danger.points_, danger.distance)
      
      checked <- init %>% state.check(danger.distance)
      safe.points <- checked %>% filter(!is.danger)
      danger.points <- checked %>% filter(is.danger)
      
      history <- rbind(history, cbind(checked, time=t))
      danger.zones[[t]] <- danger.zone
      init <- rbind(safe.points, danger.points) %>% next.location(speed)
    }
    
    list(history=history, danger.zones=danger.zones)
  }
  
  make.ggplot <- function(simulation.result){
    history <- simulation.result$history
    danger.zones <- simulation.result$danger.zones
    
    time.points <- history$time %>% unique %>% sort
    xmax <- max(history$x)
    ymax <- max(history$y)
    plot.list <- list()
    
    for(t in time.points){
      target <- history %>% filter(time == t)
      danger.zone <- danger.zones[[t]]
      
      safe.points_ <- target %>% filter(!is.danger)
      danger.points_ <- target %>% filter(is.danger) 
      
      if(nrow(safe.points_) > 0 & nrow(danger.points_) > 0){
        safe.points <- safe.points_ %>% df.to.points
        danger.points <- danger.points_ %>% df.to.points
        
        plot.list[[t]] <- 
          ggplot() + 
          geom_text(data=target, aes(x, y, label=id), vjust=-.5) +
          geom_sf(data=safe.points, colour='blue') +
          geom_sf(data=danger.points, colour='red') + 
          geom_sf(data=danger.zone, fill='red', alpha=.1, lty='dashed') + 
          theme_bw() +
          labs(title=paste('Time:', t)) +
          coord_sf(xlim=c(0, xmax), ylim=c(0, ymax))
      }else if(nrow(safe.points_) > 0){
        safe.points <- safe.points_ %>% df.to.points
        
        plot.list[[t]] <- 
          ggplot() + 
          geom_text(data=target, aes(x, y, label=id), vjust=-.5) +
          geom_sf(data=safe.points, colour='blue') +
          theme_bw() +
          labs(title=paste('Time:', t)) +
          coord_sf(xlim=c(0, xmax), ylim=c(0, ymax))
      }else if(nrow(danger.points_) > 0){
        danger.points <- danger.points_ %>% df.to.points
        
        plot.list[[t]] <- 
          ggplot() + 
          geom_text(data=target, aes(x, y, label=id), vjust=-.5) +
          geom_sf(data=danger.points, colour='red') + 
          geom_sf(data=danger.zone, fill='red', alpha=.1, lty='dashed') + 
          theme_bw() +
          labs(title=paste('Time:', t)) +
          coord_sf(xlim=c(0, xmax), ylim=c(0, ymax))
      }else{
        safe.points <- safe.points_ %>% df.to.points
        danger.points <- danger.points_ %>% df.to.points
        
        plot.list[[t]] <- 
          ggplot() + 
          geom_text(data=target, aes(x, y, label=id), vjust=-.5) +
          theme_bw() +
          labs(title=paste('Time:', t)) +
          coord_sf(xlim=c(0, xmax), ylim=c(0, ymax))
      }
      
    }
    
    plot.list
  }
  
  # server reactions ============
  
  rv <- reactiveValues()
  
  observeEvent(input$run, {
    rv$data <- infection.simulation(input$n, input$infected.rate, input$danger.distance, input$speed, input$area.length, input$time.length)
  })
  
  output$view <- renderPlot({
    if(is.null(rv$data)){
      NULL
    }else{
      rv$plot.list <- make.ggplot(rv$data)
      rv$plot.list[[min(input$selected_time, input$time.length)]]
    }
  })
}

shinyApp(ui, server)
