library(dplyr)
library(tibble)
library(rjson)

rm(list=ls())

data = tribble(
  ~session, ~json,
  'A', '{"Unit":["Marine","Medic","Tank"],"Action":"Move"}',
  'B', '{"Unit":["Marine","Medic","Tank"],"Action":"Attack","Target":"Zealot"}',
  'C', '{"Unit":["Medic"],"Action":"Heal","Target":["Marine","Ghost","Marine"]}',
  'D', '{"Unit":["SCV"],"Action":[],"Target":["Tank"]}'
) %>% as.data.frame

json_to_df = function(s){
  x = fromJSON(s)
  nx = names(x)
  res = data.frame()
  
  stopifnot(length(x) > 0)
  
  for(i in 1:length(x)){
    k = nx[i]
    v = x[[i]]
    if(length(v) > 0) res = rbind(res, data.frame(key=k, value=v))
  }
  res
}

unnest_json_col = function(df, col){
  json_col = df[, col]
  other_col = df[, -col, drop=FALSE]
  res = data.frame()
  
  suppressWarnings({
    for(i in 1:nrow(df)){
      json_elem = json_col[i]
      other_row = other_col[i, , drop=FALSE]
      
      json_df = try(json_to_df(json_elem))
      if(class(json_df) == 'try-error') next
      
      r = cbind(other_row, json_df)
      res = rbind(res, r)
    }
  })
  res
}

unnest_json_col(data, 2)
  
