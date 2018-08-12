library(dplyr)

rm(list=ls())

id <- rep(LETTERS[1:5], c(7,3,7,7,5))

page <- c(
  'main','event','bestseller','purchase','main','search','purchase',
  'main','search','purchase',
  'mypage','cart','purchase','main','free_book','purchase','mypage',
  'main','recommendation','purchase','mypage','wishlist','event','search',
  'event','purchase','mypage','cart','purchase')
  
raw.data <- 
  data.frame(id, page, stringsAsFactors=FALSE)

data <-
  raw.data %>% 
  mutate(is.purchase = ifelse(page == 'purchase', 1, 0)) %>%
  group_by(id) %>%
  mutate(is.first = abs(c(1,diff(is.purchase))) - is.purchase) %>%
  ungroup %>%
  mutate(chain.id = cumsum(is.first))

result <-
  data %>%
  group_by(id, chain.id) %>%
  summarise(page = list(page))

class(result) # grouped_df, tbl_df, tbl, data.frame
result # page column looks like <chr [4]> ...

class(result) <- 'data.frame'
result # page column show it's content well

# facebook post : other answers
# https://www.facebook.com/groups/KoreaRUsers/permalink/1223554364443930/
