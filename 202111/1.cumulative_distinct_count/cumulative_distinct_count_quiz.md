Q) 주어진 데이터셋을 이용해 주석 처리된 결과처럼 그룹별 누적매출 및 누적고객수를 구해주세요!  

---

```{r}
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

# A tibble: 8 x 4
#   group  time c_revenue c_user_count
#   <chr> <dbl>     <dbl>        <int>
# 1 a         1      1500            3
# 2 a         2      2100            3
# 3 a         3      2200            3
# 4 a         4      2400            3
# 5 b         1      1200            1
# 6 b         2      1900            2
# 7 b         3      2600            2
# 8 b         4      2900            3
```
