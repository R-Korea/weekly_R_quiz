library(ggplot2)
library(gridExtra)

# plot base
g <- 
  ggplot() + 
  theme_classic() + 
  theme(axis.title = element_blank())

# polygon : x, y : vertex
data.po <- 
  data.frame(
    x=c(0,1,1, 0,-1,-1), 
    y=c(0,1,-1, 0,1,-1))
plot.po <- 
  g + geom_polygon(data=data.po, aes(x=x, y=y)) + labs(title='Polygon')

# ribbon : x, ymin, ymax : y-range
data.ri <-
  data.frame(
    x=-1:1,
    ymin=c(-1,0,-1),
    ymax=c(1,0,1))
plot.ri <-
  g + geom_ribbon(data=data.ri, aes(x=x, ymin=ymin, ymax=ymax)) + labs(title='Ribbon')

# area : x, y : ymin = 0 ribbon
data.ar.u <-
  data.frame(
    x=c(-1,0,1),
    y=c(1,0,1))
data.ar.l <-
  data.frame(
    x=c(-1,0,1),
    y=c(-1,0,-1))
plot.ar <- 
  g + 
  geom_area(data=data.ar.u, aes(x=x, y=y)) + 
  geom_area(data=data.ar.l, aes(x=x, y=y)) + labs(title='Area')

# path : x, y : sequential points
data.pa <-
  data.frame(
    x=c(0,-1,-1, 0, 1,1,0),
    y=c(0,1,-1, 0, 1,-1,0))
plot.pa <- 
  g + geom_path(data=data.pa, aes(x=x, y=y)) + labs(title='Path')

grid.arrange(plot.po, plot.ri, plot.ar, plot.pa, ncol=2)
