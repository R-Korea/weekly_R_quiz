library(dplyr)

rm(list=ls())

polygon <- readRDS('polygons.RDS')

common.char.bin <- function(x, y, not.common='*'){
  n.max <- max(nchar(x), nchar(y))
  n.min <- min(nchar(x), nchar(y))
  
  x_ <- strsplit(x, '')[[1]]
  y_ <- strsplit(y, '')[[1]]
  
  suppressWarnings(common.idx <- x_ == y_)
  common.idx[1:n.max > n.min] <- FALSE
  
  base <- rep(not.common, n.max)
  base[common.idx] <- x_[common.idx]
  
  paste0(base, collapse='')
}

common.char <- function(x_, not.common="*"){
  bin.func <- function(x, y) common.char.bin(x, y, not.common)
  Reduce(bin.func, x_)    
}

view.data <-
  polygon %>%
  group_by(sggnm) %>%
  summarise(value = n(), hcode = common.char(hcode)) %>%
  mutate(name = paste(sggnm, ':', hcode))

view.data %>% 
  as.data.frame %>% 
  select(sggnm, hcode) %>% 
  View

# visualize ===========

if(!require('devtools')) install.packages('devtools')
if(!require('valuemap')) devtools::install_github("Curycu/valuemap")
library(valuemap)

valuemap(view.data)

# other answers =======
# https://www.facebook.com/groups/krstudy/permalink/1842401919267405
