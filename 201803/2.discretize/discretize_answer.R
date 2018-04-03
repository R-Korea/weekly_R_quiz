rm(list=ls())
set.seed(20180330)

data <- floor(100*rnorm(1000))
  
discretize <- function(num.vec, breaks=4, equal.count=FALSE, labels=NULL, right=FALSE){
  if(equal.count & length(breaks) != 1){
    stop('`equal.count=TRUE` should be with scalar type `breaks`')
  }else if(equal.count & length(breaks) == 1){
    cut(num.vec, 
        breaks=quantile(num.vec, probs=seq(0, 1, 1/breaks), na.rm=TRUE), 
        labels=labels, right=right, include.lowest=TRUE)
  }else{
    cut(num.vec, breaks=breaks, labels=labels, right=right, include.lowest=TRUE)
  }
}

library(magrittr)

# examples : parameter options
discretize(data, breaks=7, equal.count=FALSE) %>% plot(main='range cut : equal width')
discretize(data, breaks=7, equal.count=TRUE) %>% plot(main='range cut : equal count')
discretize(data, equal.count=FALSE, right=TRUE) %>% plot(main='range with right closed')
discretize(
  data, 
  breaks=c(quantile(data, probs=c(0, .3, 1))), 
  labels=c('[0%~30%)', '[30%~100%]')) %>% plot(main='(custom labels) & (manual break points)')

# error cases : `equal.count` with `manual breaks`?
discretize(data, equal.count=TRUE, breaks=c(-326, 50.6, 307))
