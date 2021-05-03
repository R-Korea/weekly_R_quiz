library(dplyr)
library(tidyr)
library(scales)
library(ggplot2)

rm(list=ls())

sample_01 <- tribble(
  ~date, ~corp, ~salary,
  '2015-01', 'A', 45000000,
  '2016-01', 'A', 46000000,
  '2017-01', 'A', 47000000,
  '2017-07', 'B', 60000000,
  '2018-01', 'B', 63000000,
  '2019-01', 'B', 66000000
)

sample_02 <- tribble(
  ~date, ~corp, ~salary,
  '2011-01', 'A', 30000000,
  '2012-01', 'A', 32500000,
  '2013-01', 'A', 35500000,
  '2014-09', 'B', 42000000,
  '2015-09', 'B', 45000000,
  '2016-09', 'B', 50000000,
  '2017-09', 'B', 54000000,
  '2017-12', 'C', 60000000 + 2400000,
  '2019-01', 'C', 65000000 + 4000000,
  '2020-12', 'D', 100000000 + 30000000
)

career_salary_graph <- function(input_table, corp_color, date_ticks='6 months', salary_ticks=5*10^6){
  
  stopifnot(!missing(input_table), !missing(corp_color))
  
  base_table <-
    input_table %>%
    mutate(
      prev = lag(salary, 1),
      increase = salary - prev,
      ratio = round(increase / prev, 3),
      corp_idx = 1,
      date = date %>% paste('01', sep='-') %>% as.Date,
      corp_idx = cumsum(ifelse(is.na(corp_idx), 0, corp_idx))
    )
  
  latest_year_salary <- input_table %>% filter(row_number() == n()) %>% .$salary
  
  base_table %>%
    transmute(
      date, corp, 
      salary = comma(salary),
      increase = comma(increase),
      ratio = percent(ratio, .1)
    ) %>% 
    print
  
  base_table %>%
    ggplot(aes(x=date, y=salary, color=reorder(corp, corp_idx), group=corp)) +
    geom_point(size=rel(2)) +
    geom_text(aes(label=corp), vjust=-1) +
    theme_bw() +
    theme(
      axis.title.y = element_text(angle=0),
      axis.text.x = element_text(angle=30),
      panel.grid.minor = element_blank(),
      legend.position = 'none'
    ) +
    scale_x_date(date_breaks=date_ticks, date_labels='%Y-%m') +
    scale_y_continuous(label=comma, breaks=seq(0, latest_year_salary + salary_ticks, salary_ticks)) +
    scale_color_manual(values=corp_color) +
    coord_cartesian(ylim=c(0, latest_year_salary)) +
    labs(title='Career Salary Graph', x=NULL, y=NULL)
}

career_salary_graph(sample_01, corp_color=c('blue','gray30'), date_tick='3 months')
career_salary_graph(sample_02, corp_color=c('red','blue','dark green','black'), salary_tick=10^7)
