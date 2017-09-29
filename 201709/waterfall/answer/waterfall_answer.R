library(dplyr)
library(ggplot2)

raw.data <- 
  data.frame(
    year=2009:2017, 
    value=c(100,110,140,160,90,30,50,150,220))

data <-
  raw.data %>%
  mutate(
    view = c(100, diff(value)), # 보이는 부분 값
    void = ifelse(view < 0, value, value - view), # 투명한 부분 값
    sign = ifelse(view < 0, '-', '+'), # 바 차트 색깔과 텍스트를 위한 컬럼
    view = abs(view)) # y축상 텍스트 위치를 위한 수정

melt.data <- # ggplot은 long 데이터만 받으므로 변형 (not wide data)
  data %>%
  select(year, view, void) %>%
  melt(id.vars='year') %>%
  setnames(c('year','visible','value'))

chart.data <- # sign 및 기타 정보를 위한 join 과 마지막 bar를 위한 rbind
  melt.data %>%
  inner_join(data %>% select(year, sign, text.position=value), by='year') %>%
  mutate(sign=ifelse(year==2009,'',sign)) %>%
  rbind(list(2018, 'view', 220, '', 220)) %>%
  rbind(list(2018, 'void', 0, '', 220))

# 차트 그리기
chart.data %>%
  ggplot(aes(x=year, y=value, alpha=visible)) +
  geom_bar(stat='identity', aes(fill=sign)) +
  scale_alpha_manual(values=c(1,0)) +
  scale_fill_manual(values=c('gray','red','black')) +
  geom_text(
    aes(
      y=ifelse(sign == '-', value+text.position, text.position), 
      label=paste(sign,value)), 
    colour='white', fontface='bold', vjust=1.2) +
  geom_text(
    aes(
      y=ifelse(sign == '-', value+text.position, text.position), 
      label=case_when(year==2009 ~ 'start', year==2018 ~ 'end', TRUE ~ as.character(year))), 
    colour='black', vjust=-0.5) +
  theme(
    panel.background = element_blank(), 
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    legend.position='none')
