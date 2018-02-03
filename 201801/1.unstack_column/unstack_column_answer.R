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
  names(res) <- colnames(d)[c(k, v)] 
  res
}

unstack.col(grade)

# restore column as stack form
stack.col <- function(d, k=1, v=2){
  kc <- as.character(unique(d[,k]))
  vc <- sapply(kc, function(x) as.character(d[d[,k]==x,][,v]))
  res <- as.data.frame(cbind(kc, vc))
  names(res) <- colnames(d)[c(k, v)] 
  res
}

stack.col(unstack.col(grade))
