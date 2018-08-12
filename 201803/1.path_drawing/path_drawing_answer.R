library(ggplot2)
library(scales)
library(dplyr)

df <- 
  data.frame(
    month = rep(1:12, 3),
    class = rep(LETTERS[1:3], each=12),
    avg.price = 
      c(1310,1200,1110,1330,1210,1530,1430,1620,1450,1320,1450,1580,
        2850,3310,3880,2750,3010,2840,2880,2940,2610,2630,2570,2790,
        2150,3130,3440,2610,2840,3900,2500,3210,2880,3430,3250,2700),
    active.user = 
      c(810,852,923,862,944,994,859,845,880,836,845,648,
        885,812,911,1033,966,894,1017,1007,935,946,922,953,
        185,312,411,533,116,224,124,501,235,452,212,153))

df %>%
  ggplot(aes(x=avg.price, y=active.user, colour=class)) +
  geom_path() +
  geom_text(
    aes(label=paste(comma(round(avg.price*active.user/10^4)),'만원')),
    fontface='bold') +
  geom_text(
    aes(label=case_when(month == 1 ~ as.character(class), TRUE ~ '')), 
    hjust=4, vjust=1, fontface='bold', size=7) +
  theme_bw() +
  theme(
    title = element_text(face='bold'),
    axis.title.y = element_text(angle=0), 
    legend.position = 'none') +
  scale_y_continuous(labels = function(x) paste(comma(x), '명'), limits = c(0,1200)) +
  scale_x_continuous(labels = function(x) paste(comma(x), '원'), limits = c(0,4500)) +
  labs(title='제품군별 고객수 객단가 추이', y='고객수', x='객단가')

# facebook post : other answers
# https://www.facebook.com/groups/KoreaRUsers/permalink/1245686742230692/
