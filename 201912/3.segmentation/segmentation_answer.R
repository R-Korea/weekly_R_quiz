library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

rm(list=ls())

set.seed(20191210)

n <- 10^2

input <- 
  data.frame(
    mob_id=1:n,
    Abuser=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.9, .1)),
    Jay_G=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.9, .1)),
    Tube=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.8, .2)),
    Frodo=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.4, .6)),
    Neo=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.4, .6)),
    Apeach=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.1, .9)),
    Muzi=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.2, .8)),
    Con=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.8, .2)),
    Ryan=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.2, .8))
  )

segments.view <- function(df){
  
  colnames(df)[1] <- 'id'
  
  base.data <-
    df %>% 
    gather('var', 'value', -id) %>%
    filter(value != 0) %>%
    select(-value)
  
  wide.data <-
    base.data %>%
    inner_join(base.data, by='id') %>%
    group_by(var.x, var.y) %>%
    summarise(user_count = length(unique(id))) %>%
    spread(var.y, user_count)
  
  wide.data[is.na(wide.data)] <- 0
  
  wide.data.matrix <- 
    wide.data[,-1] %>% as.matrix
  
  denominators <- 
    wide.data.matrix %>% diag
  
  wide.data.ratio <-
    wide.data.matrix %>% 
    '/'(., denominators) %>%
    data.frame(var.x = wide.data[,1], .)
  
  long.data.ratio <-
    wide.data.ratio %>%
    gather('var.y', 'ratio', -var.x)
    
  long.data <-
    wide.data %>%
    gather('var.y', 'user_count', -var.x)
  
  long.data %>%
    inner_join(long.data.ratio, by=c('var.x','var.y'))
}

output <- 
  segments.view(input) 

output %>%
  ggplot(aes(x=var.x, y=var.y, fill=ratio)) +
  geom_tile() +
  geom_text(aes(label=paste(comma(user_count), '\n(', percent(ratio), ')', sep='')), size=4, colour='white') +
  scale_fill_gradient(high='blue', low='gray80', label=percent) +
  labs(title='이용자 세그멘테이션 간 중첩', x='분모', y='분자', fill='비중') +
  theme_minimal() +
  theme(axis.title.y = element_text(angle=0))
