Q) 주어진 소득(= income) 데이터를 이용하여 소득상위% 당 전체소득에서 차지하는 비중을 계산하고 차트를 그려주세요!  
CMD(terminal: command line interface)에서 아래와 같은 Rscript 명령어로 실행할 수 있는 R 스크립트로 작성해야합니다!  

- 데이터 파일 : income.csv  
- 출력 파일 : inequality_result.png  

> cmd call example :  
> Rscript --encoding=UTF-8 inequality_answer.R display_ratio chart_size  
> Rscript --encoding=UTF-8 inequality_answer.R ".01 .1 .3 .5" "17.8 17.8"  

display_ratio 값을 기준으로 차트 상의 소득상위기준% 텍스트 표시 지점을 잡아줍니다
chart_size 값을 기준으로 차트의 가로, 세로 크기를 잡아줍니다

![inequality_result.PNG](inequality_result.PNG)
