library(ggplot2)
library(scales)

rm(list=ls())

set.seed(20180225)

n <- 36

profit <- 
  ts(
    data=floor(100 * (sort(rnorm(n, 0, 1)) + rnorm(n, 0, .8))), 
    start=c(2018, 1), 
    frequency=12)

ma <- function(x, window) filter(x=x, filter=rep(1/window, window))

df <-
  data.frame(
    month = seq(as.Date(0, origin="2018-01-01"), length.out=n, by="1 month"), 
    profit = as.numeric(profit),
    profit.ma3 = ma(profit, 3)) 

ggplot(data=df, aes(x=month, y=profit)) +
  geom_line() +
  geom_point() +
  geom_line(aes(x=month, y=profit.ma3), colour='red', na.rm=TRUE) +
  scale_x_date(date_labels='%Y-%m', date_breaks='3 month') +
  theme_classic() +
  labs(title='Monthly Profit: MA 3 month', x='')

# facebook post
# https://www.facebook.com/groups/KoreaRUsers/permalink/1237259443073422/
