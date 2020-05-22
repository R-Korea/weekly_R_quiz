Q) Waffle Chart 를 그려봅시다!  
  
> 조건 :
  
- 주어진 대한민국 시/도별 인구통계 이력 데이터를 tidy 하게 가공해주세요    
- 와플 차트를 그립니다  
- `shinydashboard` 패키지로 깔끔한 `tabBox` 구성을 만들어봅니다  
- `DT` 패키지로 검색, 정렬, 페이징이 가능한 테이블을 붙여줍니다  
- `showtext` 패키지로 `Nanum Pen Script` 를 받아와서 손글씨 스타일로 차트를 꾸며보세요!  
  
> 대한민국 시/도별 인구통계 이력 출처 : http://kosis.kr/statHtml/statHtml.do?orgId=101&tblId=DT_1B040A3  

---
  
![result_pic!](waffle_chart_result.PNG)  

---

```{r}
library(data.table)
library(dplyr)
library(tidyr)

library(waffle)
library(showtext)
library(shiny)
library(shinydashboard)

raw.demo <- fread('demo_1992_2019.csv', header=TRUE)
```
