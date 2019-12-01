library(dplyr)
library(data.table)

rm(list=ls())

bike <- 
  fread('bike_use_history.csv') 

not.found <-
  fread('not_found.csv') 

blacklist <- function(bike, not.found, not.found.limit){
  
  bike <- 
    bike %>%
    mutate(
      time_at = as.POSIXct(time_at, format="%Y.%m.%d_%H:%M:%S"),
      status='bike_use')
    
  not.found <-
    not.found %>%
    mutate(
      time_at = as.POSIXct(time_at, format="%Y.%m.%d_%H:%M:%S"),
      user_id = NA, status='not_found')
  
  union.base <-
    bike %>%
    union_all(not.found) %>%
    group_by(bike_id) %>%
    arrange(bike_id, time_at) %>%
    ungroup
  
  key.base <-
    union.base %>%
    group_by(bike_id) %>%
    mutate(order_per_bike = 1:n()) %>%
    mutate(
      prev_status = lag(status, 1),
      changed_status = ifelse(status == prev_status | is.na(prev_status), 0, 1),
      bike_status_id = cumsum(changed_status)) %>%
    arrange(bike_id, order_per_bike) %>%
    select(-changed_status, -prev_status) %>%
    ungroup
  
  not.found.border <-
    key.base %>%
    filter(status == 'not_found') %>%
    group_by(bike_id, bike_status_id) %>%
    mutate(
      before_not_found = min(order_per_bike) - 1,
      not_found_length = n()) %>%
    filter(not_found_length >= not.found.limit) %>%
    ungroup %>%
    select(bike_id, before_not_found, not_found_length) %>%
    distinct
  
  prev.user.mapping <- 
    key.base %>%
    select(bike_id, user_id, order_per_bike) %>%
    inner_join(not.found.border, by=c('bike_id', 'order_per_bike'='before_not_found')) %>%
    transmute(
      bike_id,
      prev_user_id = user_id,
      order_per_bike = order_per_bike + not_found_length + 1)
  
  key.base %>%
    left_join(prev.user.mapping, by=c('bike_id', 'order_per_bike')) %>% 
    mutate(is_abuser = ifelse(user_id == prev_user_id, 'abuser', NA)) %>%
    select(bike_id, user_id, time_at, status, is_abuser)
}

blacklist(bike, not.found, 5) %>% View
