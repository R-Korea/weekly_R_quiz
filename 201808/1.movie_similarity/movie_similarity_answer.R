library(dplyr)
library(data.table)
library(ggplot2)
library(scales)

rm(list=ls())

raw.data <- 
  starwars %>% 
  select(name, films)
  
# A. function to deconstruct films column : long-format
unstack.col <- function(d, k=1, v=2){
  n <- sapply(d[,v], length) 
  kc <- unlist(rep(d[,k], n, each=TRUE)) 
  vc <- unlist(d[,v]) 
  res <- data.frame(kc, vc)
  names(res) <- colnames(d)[c(k, v)] 
  res
}

# B. 0,1 binary matrix : row=name, column=film
movie.matrix <-
  raw.data %>% 
  as.data.frame %>% 
  unstack.col %>%
  dcast(name ~ films, value.var='name', fun.aggregate=length) %>% 
  select(-name) %>% 
  as.matrix

# C. calculate similarity

# C-a. empty data.table
plot.data <- 
  data.table(
    x=as.character(c()), 
    y=as.character(c()), 
    n=as.integer(c()),
    d=as.integer(c()))

# C-b. iteration for pair matching
for(i in 1:ncol(movie.matrix)){
  for(j in i:ncol(movie.matrix)){
    n <- sum(movie.matrix[,i] * movie.matrix[,j]) # numerator : intersection
    d <- sum(apply(movie.matrix[,c(i,j)], 1, max)) # denominator : union
    plot.data <- funion(plot.data, # stack pair matching result on C-a. data.table
      data.table(x=colnames(movie.matrix)[i], y=colnames(movie.matrix)[j], n=n, d=d))
  }
}

# D. plotting
plot.data %>%
  ggplot(aes(x=x, y=y, fill=n/d)) +
  geom_tile() +
  geom_text(aes(label=ifelse(x==y, paste(comma(d),'명'), percent(n/d))), fontface='bold', size=4) +
  scale_fill_gradient(low='grey90', high='red') +
  theme_classic() +
  theme(
    title = element_text(face='bold'),
    axis.title = element_blank(),
    legend.position = 'none') +
  labs(title='영화별 유사도', subtitle='Jaccard similarity')
  
# facebook post : other answers
# https://www.facebook.com/groups/KoreaRUsers/permalink/1388023107997054/
