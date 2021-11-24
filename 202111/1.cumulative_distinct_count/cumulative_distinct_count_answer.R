library(dplyr)
library(tidyr)

data = tribble(
  ~user, ~time, ~group, ~revenue,
  'A', 1, 'a', 100,
  'A', 4, 'a', 200,
  'A', 3, 'b', 700,
  'A', 2, 'b', 500,
  'B', 1, 'a', 1000,
  'B', 4, 'b', 300,
  'B', 2, 'a', 600,
  'C', 1, 'a', 400,
  'C', 3, 'a', 100,
  'C', 2, 'b', 200,
  'C', 1, 'b', 1200
) 

# Answer 1 : dplyr style  ================

data %>%
  arrange(group, time) %>%
  group_by(group) %>%
  mutate(
    c_revenue = cumsum(revenue),
    c_user_count = cumsum(!duplicated(user))
  ) %>%
  group_by(group, time) %>%
  mutate(idx = n():1) %>%
  filter(idx == 1) %>%
  ungroup %>%
  select(group, time, c_revenue, c_user_count)

# 장점 : 단순함
# 단점 : 확장성이 떨어짐 -> 누적 standard deviation 을 구하시오...?
# 보완 : 누적 데이터셋 형태로 만든 다음 group by 처리하면 모든 집계함수에 대한 확장성 확보 가능

# Answer 2 : imperative style ================

# 2-1. make cumulative data-set 
result = data.frame()
iter = data$time %>% sort %>% unique

for(i in iter){ 
  sub_data = 
    data %>% 
    filter(time <= i) %>% 
    mutate(.tidx = i)
  
  result = 
    rbind(result, sub_data)
}

result = 
  result %>% 
  mutate(time = .tidx) %>% 
  select(-.tidx)

# 2-2. summarise & display
result %>% 
  group_by(group, time) %>%
  summarise(
    c_revenue = sum(revenue),
    avg_revenue = mean(revenue),
    sd_revenue = sd(revenue),
    c_user_count = n_distinct(user)
  )

# 장점 : 확장성
# 단점 : 특정 변수가 코드 전반에 명시되어 있어 임의 변수에 대한 재사용이 불편함
# 보완 : 함수화하여 재사용성 확보 가능

# Answer 3 : make function ================

# 3-1. make cumulative data-set 
cumulative_data = function(data, colnm){
  target_col = data[[colnm]]
  
  iter = 
    target_col %>% sort %>% unique
  
  bind_f = function(u, v) 
    data %>% 
    filter(target_col <= v) %>% 
    mutate(.tidx = v) %>% 
    rbind(u, .)
  
  result = Reduce(x=iter, f=bind_f, init=data.frame())
  
  result %>% 
    mutate({{colnm}} := .tidx) %>% 
    select(-.tidx)
}

result = 
  data %>% 
  cumulative_data('time') 

# 3-2. summarise & display
result %>% 
  group_by(group, time) %>%
  summarise(
    c_revenue = sum(revenue),
    avg_revenue = mean(revenue),
    sd_revenue = sd(revenue),
    c_user_count = n_distinct(user)
  )

# 장점 : 간결함 + 확장성 + 재사용성

# another answers : 
# https://www.facebook.com/groups/krstudy/permalink/2043509812489947
