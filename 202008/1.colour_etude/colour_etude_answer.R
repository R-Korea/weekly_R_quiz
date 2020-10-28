library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

rm(list=ls())

set.seed(20191210)

n <- 10^3

input <- 
  data.frame(
    id=1:n,
    SG01=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.9, .1)),
    SG02=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.8, .2)),
    SG03=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.7, .3)),
    SG04=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.6, .4)),
    SG05=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.5, .5)),
    SG06=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.4, .6)),
    SG07=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.3, .7)),
    SG08=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.2, .8)),
    SG09=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.1, .9)),
    SG10=sample(x=c(0, 1), size=n, replace=TRUE, prob=c(.05, .95))
  )

segments.view <- function(df){
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
    inner_join(long.data.ratio, by=c('var.x','var.y')) %>%
    ungroup %>%
    transmute(
      denominator = var.x,
      numerator = var.y,
      user_count,
      ratio
    ) %>%
    arrange(
      denominator, 
      numerator
    )
}

output <- segments.view(input)

# 예전 차트
output %>%
  mutate(label_text = paste(comma(user_count, 1), '\n(', percent(ratio, 1), ')', sep='')) %>%
  ggplot(aes(x=numerator, y=denominator, fill=ratio)) +
  geom_tile() +
  geom_text(aes(label=label_text), color='white') +
  scale_fill_gradient(low='white', high='red', label=percent) +
  theme_minimal() +
  theme(axis.title.y = element_text(angle=0)) +
  labs(title='colour etude', y='denominator', x='numerator')

# 불만사항 해결 차트
output %>%
  mutate(
    ratio_label = percent(ratio, 1),
    ratio = ifelse(denominator == numerator, NA, ratio),
    text_colour = case_when(is.na(ratio) ~ 0, ratio < .4 ~ 1, TRUE ~ 2) %>% as.character,
    label_text = paste(comma(user_count, 1), '\n(', ratio_label, ')', sep='')
  ) %>%
  ggplot(aes(x=numerator, y=denominator, fill=ratio)) +
  geom_tile() +
  geom_text(aes(label=label_text, colour=text_colour)) +
  scale_fill_gradient(low='#FFFFFF', high='#FF0000', na.value='black', label=percent) +
  scale_color_manual(values=c('gold','black','white'), guide=NULL) +
  theme_minimal() +
  theme(
    title = element_text(size=24, face='bold'),
    axis.title.y = element_text(angle=0, size=11, face='bold', colour='blue'),
    axis.text.y = element_text(size=11, face='bold', colour='blue'),
    axis.title.x = element_text(size=11, face='bold', colour='grey50'),
    axis.text.x = element_text(size=11, face='bold', colour='grey50'),
    legend.position = 'none'
  ) +
  labs(title='Colour Etude', y='denominator', x='numerator')
