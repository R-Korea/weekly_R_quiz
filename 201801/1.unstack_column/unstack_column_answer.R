rm(list=ls())

grade <- 
  as.data.frame(cbind(
    ID = c(LETTERS[1:5]),
    GPA = list('A+','F', c('C-','B','A+'), c('A','A+'), 'D')
  ))

grade

# ====================

unstack.col <- function(d, k=1, v=2){
  n <- sapply(d[,v], length) 
  kc <- unlist(rep(d[,k], n, each=TRUE)) 
  vc <- unlist(d[,v]) 
  res <- data.frame(kc, vc)
  names(res) <- colnames(d) 
  res
}

unstack.col(grade)
