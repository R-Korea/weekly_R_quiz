set.seed(171124)

buy.term <- function(n) floor(rgamma(n,5,1))

terms <- matrix(buy.term(30), 10, 3)
colnames(terms) <- LETTERS[1:3]
(init.buy <- c('2017-11-01','2017-11-14','2017-11-23'))
terms

term.dates <- function(init.buy, terms){
  data <- rbind(unclass(as.Date(init.buy)), terms) # unclass로 numeric 변환, 그후 terms에 head로 rbind
  num.data <- apply(data, 2, cumsum) # terms의 누적합을 계산
  class(num.data) <- 'Date' # Date로 변환
  char.data <- as.character(num.data) # character로 변환
  res <- matrix(char.data, nrow(terms)+1, ncol(terms)) # class <- 'Date' 변환시 dimension 정보를 잃었기에 다시 추가
  colnames(res) <- colnames(terms) # 컬럼명을 붙여줌
  as.data.frame(res)
}

term.dates(init.buy, terms)
