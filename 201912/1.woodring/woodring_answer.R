library(dplyr)
library(ggplot2)
library(gridExtra)

rm(list=ls())

set.seed(20191205)

init <- c('201901','201902','201903','201904','201905','201906','201907','201908','201909','201910','201911')
after <- rep(init, times=1, each=11)

month.gap <- function(y1, m1, y0, m0) 12*(y1 - y0) + (m1 - m0)

data <-
  cbind(init, after) %>%
  as.data.frame %>%
  arrange(init) %>%
  mutate(
    init_year = as.numeric(substring(init, 1, 4)),
    init_month = as.numeric(substring(init, 5, 6)),
    after_year = as.numeric(substring(after, 1, 4)),
    after_month = as.numeric(substring(after, 5, 6)),
    month_gap = month.gap(after_year, after_month, init_year, init_month)) %>%
  filter(month_gap >= 0) %>%
  mutate(user_count = abs(floor(rnorm(n(), 0, 5)*100 + 1000)))

max.data <-
  data %>%
  group_by(init) %>%
  summarise(max_user_count = max(user_count))

data <-
  data %>%
  inner_join(max.data, by=('init')) %>%
  mutate(user_count = ifelse(month_gap == 0, max_user_count, user_count))
  
total <-
  data %>%
  group_by(after) %>%
  summarise(total_user_count = sum(user_count))

# 나이테 차트
p1 <- 
  data %>%
  inner_join(total, by = 'after') %>%
  mutate(ratio = user_count / total_user_count) %>%
  group_by(after) %>%
  arrange(after, desc(init)) %>%
  mutate(yloc = cumsum(user_count) - user_count/2) %>%
  ggplot(aes(x = after, y = user_count, fill = init)) +
  geom_bar(stat='identity') +
  geom_text(aes(label = ifelse(ratio < .005, '', scales::percent(ratio, 1)), y = yloc)) +
  scale_fill_brewer(palette = 'Spectral') +
  scale_y_continuous(labels = scales::comma) +
  labs(title = '나이테 차트', x = '이용월', y = '고객수', fill = '최초이용월') +
  theme_bw() +
  theme(axis.text.x = element_text(angle=20))

# 나이테 차트 중 최초이용고객수
p2 <-
  data %>%
  inner_join(total, by = 'after') %>%
  mutate(ratio = user_count / total_user_count) %>%
  group_by(after) %>%
  arrange(desc(init)) %>%
  mutate(yloc = cumsum(user_count) - user_count/2) %>%
  ungroup %>%
  mutate(is_init = ifelse(month_gap == 0, 'init', 'not_init')) %>%
  ggplot(aes(x = after, y = user_count, fill = is_init)) +
  geom_bar(stat = 'identity', position = position_stack(reverse = TRUE)) +
  geom_text(aes(label = ifelse(month_gap > 0, '', scales::percent(ratio, 1)), y = yloc)) +
  scale_fill_brewer(palette = 'Spectral') +
  scale_y_continuous(labels = scales::comma) +
  labs(title = '나이테 차트', subtitle = '- 최초이용고객', x = '이용월', y = '고객수', fill = '최초이용월') +
  theme_bw() +
  theme(axis.text.x = element_text(angle=20))

grid.arrange(p1, p2, ncol=1)

