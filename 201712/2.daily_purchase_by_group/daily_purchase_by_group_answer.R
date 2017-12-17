library(dplyr)
library(ggplot2)
library(scales)
library(stringr)

rm(list=ls())

set.seed(171215)

user.count <- 950

user_reservation <- 
  data.frame(
    idx = 1:user.count,
    user.id = paste('u_', str_pad(1:user.count, 3, pad='0'), sep=''),
    cancel = ifelse(runif(user.count, 0, 1) > .9, 'Y', 'N')) %>%
  mutate(idx.group = floor((idx-1)/100)+1)

first.open <- as.Date('2017-12-13')

purchase_open_date <-
  data.frame(
    idx.group = 1:10,
    open.date = first.open + sort(sample(0:20,10,replace=TRUE)))

purchase <-
  user_reservation %>%
  inner_join(purchase_open_date, by='idx.group') %>%
  mutate(
    buy.date = open.date + floor(rexp(user.count, 1)),
    buy.date = ifelse(cancel == 'Y', NA, buy.date),
    buy.date = ifelse(runif(user.count, 0, 1) > .9, NA, buy.date),
    buy.date = as.Date(buy.date, origin='1970-01-01'),
    day.gap = as.numeric(difftime(buy.date, open.date, units='days')))

# =================================

group_count <-
  user_reservation %>% 
  group_by(idx.group) %>%
  summarise(
    total.count = n(),
    cancel.count = sum(ifelse(cancel == 'Y',1,0)))

group_gap_count <-
  purchase %>%
  group_by(idx.group, day.gap) %>%
  summarise(
    buy.count = sum(ifelse(!is.na(buy.date),1,0))) %>%
  filter(!is.na(day.gap))

plot.data <-
  group_count %>%
  inner_join(group_gap_count, by='idx.group') %>%
  mutate(
    buy.ratio = buy.count/total.count,
    cancel.ratio = cancel.count/total.count)

na.omit.unique <- function(x) x[!is.na(x)] %>% unique

y.breaks <- user_reservation$idx.group %>% na.omit.unique %>% max %>% 1:.
x.breaks <- purchase$day.gap %>% na.omit.unique %>% max %>% 0:.

y.label.func <- function(x) paste('Grp', str_pad(x, 2, pad='0'), sep=':')
x.label.func <- function(x) paste(x, 'day', sep='')

plot.data %>%
  ggplot(aes(x=day.gap, y=idx.group, fill=buy.ratio)) +
  geom_tile() +
  geom_text( # buy rate display
    aes(label=
          paste('buy:', percent(buy.ratio))), 
    colour='black', fontface='bold', vjust=-.5) +
  geom_text(
    aes(label=
          case_when( # cancel rate display 
            day.gap == 0 ~ paste('cancel:', percent(cancel.ratio)), 
            TRUE ~ '')), 
    colour='white', fontface='bold', vjust=1) +
  scale_fill_gradient(high='red', low='white') + # from white to red
  scale_y_reverse(breaks=y.breaks, labels=y.label.func) + # reverse y axis order
  scale_x_continuous(breaks=x.breaks, labels=x.label.func) + # discretize x axis by breaks
  theme_bw() +
  theme(
    title = element_text(face='italic', colour='red', size=12),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    legend.position = 'none') +
  labs(title='구매가능일 기준 예약 실구매율')
