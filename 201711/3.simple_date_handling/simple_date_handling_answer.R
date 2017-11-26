set.seed(171124)

buy.term <- function(n) floor(rgamma(n,5,1))

terms <- matrix(buy.term(30), 10, 3)
colnames(terms) <- LETTERS[1:3]
(init.buy <- c('2017-11-01','2017-11-14','2017-11-23'))
terms

term.dates <- function(init.buy, terms){
  data <- rbind(unclass(as.Date(init.buy)), terms) # cast as numeric & add numeric init.date to terms as head of columns 
  num.data <- apply(data, 2, cumsum) # calculate cummulative terms
  class(num.data) <- "Date" # cast as Date
  char.data <- as.character(num.data) # cast as character
  res <- matrix(char.data, nrow(terms)+1, ncol(terms)) # add dimension since class method remove dimension info
  colnames(res) <- colnames(terms) # tag column name
  as.data.frame(res)
}

term.dates(init.buy, terms)