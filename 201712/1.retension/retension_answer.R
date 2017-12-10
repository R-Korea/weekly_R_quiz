library(dplyr)
library(data.table)

rm(list=ls())

raw.data <-
  data.frame(
    user.id = c(
      rep('A',4),rep('B',3),rep('C',5),rep('D',4),rep('E',4),rep('F',1),
      rep('G',7),rep('H',6),rep('I',8),rep('J',7),rep('K',2),rep('L',3)),
    buy.date = c(
      '2017-01-01','2017-01-02','2017-01-03','2017-01-15',
      '2017-01-02','2017-01-03','2017-01-04',
      '2017-01-02','2017-01-03','2017-01-05','2017-01-11','2017-01-18',
      '2017-01-03','2017-01-04','2017-01-05','2017-01-15',
      '2017-01-04','2017-01-05','2017-01-06','2017-01-17',
      '2017-01-04',
      '2017-01-04','2017-01-05','2017-01-06','2017-01-15','2017-01-16','2017-01-17','2017-01-20',
      '2017-01-05','2017-01-06','2017-01-07','2017-01-15','2017-01-16','2017-01-21',
      '2017-01-06','2017-01-07','2017-01-08','2017-01-15','2017-01-16','2017-01-20','2017-01-21','2017-01-22',
      '2017-01-08','2017-01-10','2017-01-11','2017-01-15','2017-01-16','2017-01-17','2017-01-21',
      '2017-01-08','2017-01-11',
      '2017-01-10','2017-01-11','2017-01-13')) %>%
  mutate(buy.date = as.Date(buy.date))

# ===========================================

distinct.count <- function(x) length(unique(x[!is.na(x)]))

# 고객별 최초 구매일자
init.buy <- 
  raw.data %>%
  group_by(user.id) %>%
  summarise(init.date = min(buy.date))

# 구매 데이터와 최초 구매일자 정보 결합
data <-
  init.buy %>%
  inner_join(raw.data, by=c('user.id'))

# 최초 구매일과 구매일 간 날짜 차이 계산 (= gap)
mid.data <-
  data %>% 
  mutate(gap = as.numeric(difftime(buy.date, init.date, units='days')))

# 잔류율 빈 일자 채워주기 위한 연속적인 일자
dense.days <- data.frame(gap=0:max(mid.data$gap)) 

res <-
  mid.data %>%
  right_join(dense.days, by='gap') %>% # 잔류율 빈 일자 채워주기 위함
  dcast(init.date ~ gap, value.var='user.id', fun.aggregate=distinct.count) %>% 
  .[!is.na(.$init.date),] %>% # right join으로 생긴 NA row 삭제
  setNames(c(names(.)[1], paste('d',names(.)[-1], sep='-')))

res
