library(dplyr)
library(data.table)
library(ggplot2)

r <- 10
x <- -r:r

data <- data.frame(x=x, y=sqrt(r^2-(x)^2))

data %>%
  ggplot(aes(x=x, y=y)) +
  geom_point(alpha=1-abs(x)/max(x), size=10-abs(x), colour='yellow') +
  geom_bar(
    aes(y=rev(abs(cos(x) - 0.5*(1:length(x))))), 
    stat='identity', 
    fill='gray80', 
    width=0.3) +
  geom_line(stat='identity', y=rev(abs(cos(x) - 0.5*(1:length(x)))), colour='white', linetype='dashed') +
  theme(
    legend.position = 'none',
    panel.background = element_rect(fill='black'),
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    title = element_text(size=20, face='bold')) +
  geom_text(x=7, y=10.5, label='즐거운 한가위 되세요~', colour='#f2ca5c', fontface='bold', size=7)