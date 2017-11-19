library(dplyr)
library(ggplot2)

mtcars %>%
  mutate(car.name=rownames(.)) %>%
  arrange(cyl, hp) %>%
  mutate(order.key=1:n()) -> data

data %>%
  ggplot(aes(x=hp, y=reorder(car.name, order.key))) +
  geom_point(
    colour=case_when(
      data$car.name %in% c('Ferrari Dino','Maserati Bora') ~ 'red', 
      TRUE ~ 'black')) +
  geom_hline(yintercept = 11.5, linetype='dashed') +
  geom_hline(yintercept = 18.5, linetype='dashed') +
  facet_wrap(~ cyl, labeller = label_both) +
  scale_x_continuous(limits=c(0,max(data$hp))) +
  theme_bw() +
  theme(axis.title.y=element_blank())