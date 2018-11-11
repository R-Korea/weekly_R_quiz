library(dplyr)
library(stringr)

rm(list=ls())

data <-
  data.frame(
    address_1 = c(
      '경기도 수원시 장안구 파장1동 삼호빌라 B동',
      '수원시 정자2동 백설마을 주공아파트 571동 103-1023',
      '경기도 정자동 현준맨션 2동',
      '경기도 장안구 정자1동 e편한 맨션 310-7번지',
      '서울시 동작구 사당1동',
      '서울시 문래동 1가 200-1',
      '경상북도 안동시 안기동 20-1 ',
      '서문래2동 '), 
    stringsAsFactors=FALSE)

answer <-
  data %>%
  mutate(address_2 = str_match(string=address_1, pattern='(.+?동 )')[,2]) %>%
  mutate(address_2 = ifelse(is.na(address_2), address_1, address_2))

# facebook post : other answers
# https://www.facebook.com/groups/KoreaRUsers/permalink/1454529008013130/

# 실주소 예제 확인 방법
# 도로명주소 안내 홈페이지 > 개발자센터 > 건물DB 다운로드 
# http://www.juso.go.kr/addrlink/addressBuildDevNew.do?menu=rdnm
