library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(gridExtra)

set.seed(7)

df <-
  data.frame(
    id = 1:10, 
    from = as.Date(Sys.Date()) + sample(1:20, 10, TRUE)) %>% 
  mutate(
    to = from + sample(3:10, 10, TRUE))

res <- 
  df %>%
  rowwise %>%
  mutate(day.gap = list(0:(to - from))) %>%
  unnest(day.gap) %>%
  mutate(active = from + day.gap)

p <- 
  df %>% 
  ggplot() +
  geom_segment(aes(x=from, y=id, xend=to, yend=id)) +
  geom_segment(aes(x=from, y=id - .1, xend=from, yend=id + .1)) +
  geom_segment(aes(x=to, y=id - .1, xend=to, yend=id + .1)) +
  geom_text(aes(x=from, y=id, label=id), hjust=1.5, col='red') +
  scale_x_date(date_labels = "%d", date_breaks='1 day') +
  scale_y_continuous(breaks=1:10) +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle=30),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.title = element_blank()) +
  labs(title = '사용자별 이용권 기간')

p2 <- 
  res %>%
  group_by(active) %>%
  summarise(user.count = length(unique(id))) %>%
  ggplot(aes(x=active, y=user.count)) +
  geom_bar(stat='identity') +
  scale_x_date(date_labels = "%d", date_breaks='1 day') +
  scale_y_continuous(breaks=1:10, labels=function(x) paste(x,'명',sep='')) +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle=30),
    axis.title = element_blank()) +
  labs(title = '기간별 유효한 사용자')

grid.arrange(p, p2, ncol=2)

# facebook post : other answers
# https://www.facebook.com/groups/krstudy/permalink/1101943866646551/
