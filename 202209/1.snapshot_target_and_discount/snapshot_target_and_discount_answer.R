library(tidyr)
library(dplyr)
library(scales)

rm(list=ls())

snapshot = tribble(
  ~snapshot_dt, ~item, ~unit_available,
  '2022-08-01', 'A', 500, 
  '2022-08-08', 'A', 470, 
  '2022-08-15', 'A', 350, 
  '2022-08-15', 'B', 350, 
  '2022-08-22', 'A', 150, 
  '2022-08-22', 'B', 150, 
  '2022-08-29', 'A', 50 
)

order = tribble(
  ~order_dttm, ~item, ~unit_sold,
  '2022-08-01 13:30', 'A', 	10 ,
  '2022-08-02 17:13', 'A', 	50 ,
  '2022-08-07 15:03', 'A',  -30 ,
  '2022-08-09 02:01', 'A', 	80 ,
  '2022-08-10 00:03', 'A', 	20 ,
  '2022-08-11 20:10', 'A', 	20 ,
  '2022-08-20 06:17', 'A', 	200, 
  '2022-08-20 06:17', 'B', 	500, 
  '2022-08-23 00:00', 'A', 	20 ,
  '2022-08-23 04:03', 'A', 	90 ,
  '2022-08-28 00:30', 'A',  -10 
)

latest_snapshot = 
  snapshot %>%
  group_by(item) %>%
  mutate(rev_rank = n():1) %>%
  filter(rev_rank == 1) %>%
  select(-rev_rank) %>%
  ungroup

total_sold = 
  order %>%
  group_by(item) %>%
  summarise(unit_sold = sum(unit_sold)) %>%
  ungroup

dashboard = 
  latest_snapshot %>%
  inner_join(total_sold, by='item') %>%
  transmute(
    item,
    unit_available = unit_available + unit_sold,
    unit_sold,
    unit_sold_percentage = unit_sold / unit_available
  )

dashboard %>%
  mutate_at('unit_sold_percentage', percent) %>%
  arrange(item)
