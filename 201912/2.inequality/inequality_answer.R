# cmd call example : 
# Rscript --encoding=UTF-8 inequality_answer.R display_ratio chart_size
# Rscript --encoding=UTF-8 inequality_answer.R ".01 .1 .3 .5" "17.8 17.8"

# needed packages
package.list <- 
  c('dplyr','ggplot2','data.table','stringr','extrafont')

# not installed packages among needed packages
not.found.packages <- 
  package.list[!package.list %in% installed.packages()[,1]]

# set repos : cran.rstudio.com
repos <- c('https://cran.rstudio.com/')
names(repos) <- 'CRAN'

# install.packages
sapply(
  not.found.packages, 
  function(x) install.packages(pkgs=x, repos=repos, type='binary', quiet=TRUE))
  
# load packages
sapply(
  package.list, 
  function(x) library(x, character.only=TRUE))

rm(list=ls())

cmd.input <- commandArgs(trailingOnly=TRUE)
display.ratios <- cmd.input[1] %>% str_split(' ') %>% .[[1]] %>% as.numeric
chart.size <- cmd.input[2] %>% str_split(' ') %>% .[[1]] %>% as.numeric

raw.data <- fread('income.csv', encoding='UTF-8')

data <- 
  raw.data %>%
  arrange(desc(income)) %>%
  mutate(
    order_key=1:n(),
    max_order_key=max(order_key),
    ratio = round(order_key / max_order_key, 3),
    cumsum_income = cumsum(income),
    total_income = max(cumsum_income),
    income_ratio = round(cumsum_income / total_income, 3)
  ) %>%
  arrange(ratio)

p <- 
  data %>%
  ggplot(aes(x=ratio, y=income_ratio)) +
  geom_line(stat='identity') +
  geom_text(aes(label=ifelse(ratio %in% display.ratios, scales::percent(ratio, 1), ''), hjust=-.3)) +
  geom_text(aes(label=ifelse(ratio %in% display.ratios, scales::percent(income_ratio, .1), ''), hjust=1.2, colour='red')) +
  theme_bw(base_family = 'NanumGothic') +
  theme(
    legend.position = 'none',
    panel.grid = element_blank()) +
  scale_y_continuous(labels=function(x) scales::percent(x, 2), breaks=seq(0, 1, .1)) +
  scale_x_continuous(labels=function(x) scales::percent(x, 2), breaks=seq(0, 1, .1), expand = rep(.05, 4)) +
  labs(title='소득상위%별 전체소득비중', x='소득상위%', y='전체소득비중', colour='')

ggsave(
  plot=p, 
  filename='inequality_result.png', 
  width=chart.size[1], 
  height=chart.size[2],
  units='cm',
  device='png'
)

write.csv(data, 'inequality_result.csv', row.names=FALSE)
