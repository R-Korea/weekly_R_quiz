library(ggplot2)
library(dplyr)
library(gridExtra)

korea <-
  map_data('world') %>% 
  filter(region %in% c('North Korea','South Korea'))

united.korea <-
  korea %>%
  mutate(region = 'Korea')

clean.theme <-
  theme_bw() +
  theme(
    text = element_blank(),
    line = element_blank(),
    legend.position = 'none')

p1 <-
  ggplot(korea) +
  geom_polygon(aes(x=long, y=lat, group=group, fill=region), colour=NA) +
  scale_fill_manual(values=c('red','blue')) +
  clean.theme

p2 <-
  ggplot(united.korea) +
  geom_polygon(aes(x=long, y=lat, group=group, fill=region), colour=NA) +
  scale_fill_manual(values=c('skyblue')) +
  clean.theme

grid.arrange(p1, p2, ncol=2)

# facebook post : other answers
# https://www.facebook.com/groups/KoreaRUsers/permalink/1276993862433313/
# https://www.facebook.com/groups/krstudy/permalink/973111089529830/
