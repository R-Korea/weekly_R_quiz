library(dplyr)
library(data.table)
library(ggplot2)

rm(list=ls())
  
scale_zero_to_one <- 
  function(x) {
    r <- range(x, na.rm = TRUE)
    min <- r[1]
    max <- r[2]
    (x - min) / (max - min)
  }

scaled.data <-
  mtcars %>%
  lapply(scale_zero_to_one) %>%
  as.data.frame %>%
  mutate(car.name=rownames(mtcars)) 

plot.data <-
  scaled.data %>%
  melt(id.vars='car.name') %>%
  rbind(subset(., variable == names(scaled.data)[1]))

# inherit coord_polar
coord_radar <- 
  function(theta='x', start=0, direction=1){
    # input parameter sanity check
    match.arg(theta, c('x','y'))
    
    ggproto(
      NULL, CoordPolar, 
      theta=theta, r=ifelse(theta=='x','y','x'),
      start=start, direction=sign(direction),
      is_linear=function() TRUE)
  }

plot.data %>%
  ggplot(aes(x=variable, y=value, group=car.name, colour=car.name)) + 
  geom_path() +
  geom_point(size=rel(0.9)) +
  coord_radar() + 
  facet_wrap(~ car.name, nrow=4) + 
  theme_bw() +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.title.x = element_blank(),
    legend.position = 'none') +
  labs(title = "Cars' Status")
