library(tm)

raw.data <- 
  data.frame(
    id = LETTERS[1:4],
    content = c('a,b,c,d','a,d','c,c,e,a','b,b,b'))

data <- 
  gsub(',',' ',raw.data$content)

names(data) <- 
  raw.data$id

corp <- 
  Corpus(VectorSource(data))

tdm <-
  TermDocumentMatrix(corp, control=list(wordLengths=c(1,Inf)))

t(as.matrix(tdm))
