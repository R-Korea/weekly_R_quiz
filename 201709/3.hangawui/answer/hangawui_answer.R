library(dplyr)
library(data.table)
library(ggplot2)

set.seed(1004)

r <- 10
x <- -r:r

moons <- 
  data.frame(
    x = x, 
    y = 1.2*sqrt(r^2 - x^2))

stars <- 
  data.frame(
    x=x*0.8, 
    y=ifelse(x < 4, -1, max(x) + 0.1*x + rnorm(length(x))))

mountains <- 
  data.frame(
    x=x, 
    y=rev(abs(cos(x) - 0.5*(1:length(x)))) + rnorm(length(x)))
  
ggplot(NULL) +
  
  # draw moons
  geom_point(aes(moons$x, moons$y), alpha=1-abs(x)/max(x), size=10-abs(x), colour='yellow') +
  
  # draw stars
  geom_point(aes(stars$x, stars$y), colour='white') +
  geom_line(aes(stars$x, stars$y), colour='white', linetype='dashed') +
  
  # draw mountains
  geom_bar(aes(mountains$x, mountains$y), stat='identity', fill='#5a7f48', width=0.3) +
  geom_line(aes(mountains$x, mountains$y), colour='green', linetype='dashed') +
  
  # write the message
  geom_text(aes(x=7, y=13.5), label='즐거운 한가위 되세요~', colour='yellow', fontface='italic', size=7) +
  
  # background settings
  theme(
    legend.position = 'none',
    panel.background = element_rect(fill='black'),
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    title = element_text(size=20, face='bold')) +
  scale_y_continuous(limits=c(0, max(moons$y)*1.2))
