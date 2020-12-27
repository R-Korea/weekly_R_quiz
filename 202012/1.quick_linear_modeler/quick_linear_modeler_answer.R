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
  rv <- reactiveValues()
  
  observeEvent(input$train_data, {
    file <- input$train_data
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    validate(need(ext %in% c("csv",'xlsx','xls'), 'Please upload a csv | xlsx | xls file'))
    
    rv$train_data <- if(ext == 'csv') {
      read.csv(file$datapath, header=TRUE)
    }else{
      read_excel(file$datapath, col_names=TRUE)
    }
    
    output$columns <- DT::renderDataTable(
      rv$train_data[1,] %>% 
        sapply(function(x) class(x)) %>%
        as.data.frame %>%
        setnames('type') %>%
        transmute(name=row.names(.), type),
      rownames=FALSE,
      options=list(pageLength=20)
    )
    
    output$message_box <- renderText({'Train data is loaded'})
  })
  
  observeEvent(input$test_data, {
    file <- input$test_data
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    validate(need(ext %in% c("csv",'xlsx','xls'), 'Please upload a csv | xlsx | xls file'))
    
    rv$test_data <- if(ext == 'csv') {
      read.csv(file$datapath, header=TRUE)
    }else{
      read_excel(file$datapath, col_names=TRUE)
    }
    
    output$columns <- DT::renderDataTable(
      rv$test_data[1,] %>% 
        sapply(function(x) class(x)) %>%
        as.data.frame %>%
        setnames('type') %>%
        transmute(name=row.names(.), type),
      rownames=FALSE,
      options=list(pageLength=20)
    )
    
    output$message_box <- renderText({'Test data is loaded'})
  })

  observeEvent(input$run, {
    
    req(!is.null(rv$train_data) & !is.null(rv$test_data))
    output$message_box <- renderText({'Fit model to data...'})
    
    # Data setting
    formula <- eval(parse(text=input$formula))
    
    train_data <- rv$train_data %>% filter(complete.cases(.))
    test_data <- rv$test_data %>% filter(complete.cases(.))
    
    data <- 
      rbind(
        train_data %>% mutate(type = 'train'), 
        test_data %>% mutate(type = 'test')
      )
    
    x_axis_order_col <-
      if(input$x_axis_order_col == ''){
        colnames(data)[1]
      }else{
        input$x_axis_order_col
      }
    
    train.y <- all.vars(formula)[1] %>% train_data[.] %>% unlist
    train.x <- model.matrix(formula, train_data)[, -1, drop=FALSE]
    
    test.y <- all.vars(formula)[1] %>% test_data[.] %>% unlist
    test.x <- model.matrix(formula, test_data)[, -1, drop=FALSE]
    
    x <- rbind(train.x, test.x)
    y <- c(train.y, test.y)
    
    # Calculations
    rmse <- function(real, pred){
      sum.of.squares <- sum((real - pred)^2)
      obs.num <- length(real)
      mse <- sum.of.squares / obs.num
      sqrt(mse)
    }
    
    # Model Fitting : ols, ridge, lasso
    if(input$reg_type == 'ols'){
      tryCatch({
        rv$model <- 
          lm(formula, train_data)
        
        rv$result <-
          data %>%
          mutate(
            idx = 1:n(),
            real = y,
            pred = predict(rv$model, type='response', newdata=data),
            gap = real - pred
          )
        
        rv$coef.wide <-
          data.frame(
            coef = rv$model %>% coef %>% round(., 4)
          ) %>%
          mutate(var = rownames(.)) %>%
          select(var, coef)
        },
        error = function(e) { output$message_box <- renderText({e}) }
      )
    }else if(input$reg_type == 'ridge'){
      tryCatch({
        rv$model <- 
          cv.glmnet(train.x, train.y, alpha=0, nfolds=5)
        
        rv$result <-
          data %>%
          mutate(
            idx = 1:n(),
            real = y,
            pred = predict(rv$model, type='response', s=rv$model$lambda.min, newx=x),
            gap = real - pred) 
        
        rv$coef.wide <-
          data.frame(
            coef = rv$model %>% coef(s=.$lambda.min) %>% .[,1] %>% round(., 4)
          ) %>%
          mutate(var = rownames(.)) %>%
          select(var, coef)
        },
        error = function(e) { output$message_box <- renderText({as.character(e)}); req(FALSE) }
      )
    }else{
      tryCatch({
        rv$model <- 
          cv.glmnet(train.x, train.y, alpha=1, nfolds=5)
        
        rv$result <-
          data %>%
          mutate(
            idx = 1:n(),
            real = y,
            pred = predict(rv$model, type='response', s=rv$model$lambda.min, newx=x),
            gap = real - pred) 
        
        rv$coef.wide <-
          data.frame(
            coef = rv$model %>% coef(s=.$lambda.min) %>% .[,1] %>% round(., 4)
          ) %>%
          mutate(var = rownames(.)) %>%
          select(var, coef) 
        },
        error = function(e) { output$message_box <- renderText({as.character(e)}); req(FALSE) }
      )
    }
    
    rmse.model <- 
      rmse(
        real=test.y, 
        pred=rv$result %>% filter(type == 'test') %>% .$pred
      )
    
    # charting
    plot.model <- function(pred, gap, rmse, title){
      rv$result %>%
        ggplot(aes(x=reorder(idx, !!sym(x_axis_order_col)), y=real, group=1)) +
        geom_line() +
        geom_line(aes(y=pred), lty='dashed') +
        geom_bar(aes(y=gap), stat='identity', width=.8) +
        scale_fill_manual(values=c('gray30')) +
        scale_colour_manual(values=c('gray30')) +
        labs(
          title=title, subtitle=paste('Test RMSE', round(rmse, 2), sep=': '), 
          x='obs_idx', y='target', fill='', colour='') +
        theme_bw() +
        theme(axis.text.x = element_text(angle=30))
    }
    
    p.coef <-
      rv$coef.wide %>%
      ggplot(aes(x=var, y=coef)) +
      geom_bar(stat='identity', width=.5) +
      coord_flip() +
      labs(title='Coefficients', x='', y='') +
      theme_bw() +
      theme(
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank())
    
    p.model <- 
      plot.model(result$pred, result$gap, rmse.model, input$reg_type)
    
    output$chart <- renderPlot({ p.coef | p.model })
    
    output$coef <- DT::renderDataTable(
      rv$coef.wide,
      rownames=FALSE,
      options=list(pageLength=20)
    )
    
    output$message_box <- renderText({'Fitting complete'})
  })
  
  output$download <- downloadHandler(
    filename = function() {
      paste('quick_linear_modeler_', input$reg_type, '_', Sys.Date(), ".rds", sep='')
    },
    content = function(file) {
      output$message_box <- renderText({'Download complete'})
      saveRDS(rv$model, file)
    }
  )
}

shinyApp(ui, server)
