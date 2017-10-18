data <- c(10:5, 7:5, 4:1, 2)

df <- data.frame(data)
df <- cbind(df, cummin(data))
df <- cbind(df, sanity=ifelse(df[,1]-df[,2] > 0, 0, 1))
df <- df[,-2]
df
