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
  filter(complete.cases(.))

train.idx <- 
  1:(nrow(data)*2/3)


# Data Split by Formula : glmnet needs
y <- 
  as.character(formula)[2] %>%
  data[.] %>% unlist

x <- 
  model.matrix(formula, data)[,-1]

train.x <- x[train.idx,]
train.y <- y[train.idx]

test.x <- x[-train.idx,]
test.y <- y[-train.idx]


# Model Fitting
ols <- lm(formula, data[train.idx,])
ridge <- cv.glmnet(train.x, train.y, alpha=0, nfolds=5)
lasso <- cv.glmnet(train.x, train.y, alpha=1, nfolds=5)


# Calculations
rmse <- function(real, pred){
  sum.of.squares <- sum((real - pred)^2)
  obs.num <- length(real)
  mse <- sum.of.squares / obs.num
  sqrt(mse)
}

result <-
  data %>%
  mutate(
    idx = 1:n(),
    real = y,
    type = ifelse(idx %in% train.idx, 'train', 'test'),
    pred.ols = predict(ols, type='response', newdata=data),
    pred.ridge = predict(ridge, type='response', s=ridge$lambda.min, newx=x),
    pred.lasso = predict(lasso, type='response', s=lasso$lambda.min, newx=x),
    gap.ols = real - pred.ols,
    gap.ridge = real - pred.ridge,
    gap.lasso = real - pred.lasso) %>%
  mutate(
    rmse.ols = rmse(real=test.y, pred=.[-train.idx,]$pred.ols),
    rmse.ridge = rmse(real=test.y, pred=.[-train.idx,]$pred.ridge),
    rmse.lasso = rmse(real=test.y, pred=.[-train.idx,]$pred.lasso))

coefficients <-
  data.frame(
    OLS = ols %>% coef,
    Ridge = ridge %>% coef(s=.$lambda.min) %>% .[,1],
    Lasso = lasso %>% coef(s=.$lambda.min) %>% .[,1]
  ) %>%
  mutate(variable = rownames(.)) %>%
  gather(key='model', value='coef', 1:3)


# Charts
plot.model <- function(pred, gap, rmse, title){
  result %>%
    ggplot(aes(x=idx, y=real, colour=type)) +
    geom_line() +
    geom_line(aes(y=pred), lty='dashed') +
    geom_bar(aes(y=gap, fill=type), stat='identity', width=.8) +
    scale_fill_manual(values=c('gray30','gray70')) +
    scale_colour_manual(values=c('gray30','gray70')) +
    labs(
      title=title, subtitle=paste('Test RMSE', round(rmse, 2), sep=': '), 
      x='obs_idx', y='target', fill='', colour='') +
    theme_bw()
}

p.ols <- 
  plot.model(
    result$pred.ols, 
    result$gap.ols, 
    result$rmse.ols, 'OLS')

p.ridge <- 
  plot.model(
    result$pred.ridge, 
    result$gap.ridge, 
    result$rmse.ridge, 'Ridge')

p.lasso <- 
  plot.model(
    result$pred.lasso, 
    result$gap.lasso, 
    result$rmse.lasso, 'Lasso')

p.coef <-
  coefficients %>%
  ggplot(aes(x=variable, y=coef, group=model)) +
  geom_bar(stat='identity', width=.5) +
  coord_flip() +
  facet_grid(~ model) +
  labs(title='Compare Coefficients', x='', y='') +
  theme_bw() +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank())

grid.arrange(
  p.coef, p.ols, 
  p.ridge, p.lasso, ncol=2)
