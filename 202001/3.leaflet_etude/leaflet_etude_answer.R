library(dplyr)
library(stringr)
library(sf)
library(leaflet)
library(htmltools)

# references : https://rstudio.github.io/leaflet/choropleths.html

rm(list=ls())

points <- readRDS('points.RDS')
polygons <- readRDS('polygons.RDS')

poly.sum <-
  polygons %>%
  st_intersection(points$geometry) %>% 
  group_by(adm_cd, adm_nm) %>%
  summarise(counts = n()) %>%
  arrange(desc(counts)) %>%
  ungroup %>%
  as.data.frame %>%
  mutate(adm_nm_last = str_split(adm_nm, ' ') %>% sapply(function(x) x[3])) %>%
  select(adm_cd, adm_nm_last, counts)
  
view.data <-
  polygons %>%
  select(adm_cd) %>%
  inner_join(poly.sum, by='adm_cd') %>%
  transmute(id = adm_cd, name = adm_nm_last, value = counts)

pretty.view <- function(data, 
                        legend.cut=Inf, 
                        map.provider=providers$CartoDB.DarkMatter, 
                        palette.name='Blues'){
  
  # polygon label info
  centers <- 
    suppressWarnings(st_centroid(data))
  
  labels <- 
    sprintf('<strong>%s</strong><br/>value : %g', data$name, data$value) %>% lapply(HTML)
  
  los <- 
    labelOptions(style=list('font-weight'='normal', padding='3px 8px'), textsize='15px', direction='auto')
  
  hos <- 
    highlightOptions(weight=5, color='white', dashArray='', fillOpacity=.7, bringToFront=TRUE)
  
  # marker label info
  marker.labels <- 
    sprintf('<strong>%g</strong>', data$value) %>% lapply(HTML)
  
  marker.los <- 
    labelOptions(noHide=TRUE, direction='center', textOnly=TRUE, textsize='12px')
  
  # legend info
  bins <- suppressWarnings({
    if(legend.cut == Inf){
      data$value %>% summary %>% unclass %>% unique
    }else{
      legend.cut
    }
  })

  pals <- 
    colorBin(palette.name, domain=data$value, bins=bins)
  
  # draw plot
  leaflet(data) %>%
    addProviderTiles(provider=map.provider) %>%
    addPolygons(
      color='white', weight=2, opacity=1, dashArray=3, 
      fillColor=~pals(value), fillOpacity=1, 
      highlight=hos, label=labels, labelOptions=los
    ) %>%
    addLabelOnlyMarkers(data=centers, label=marker.labels, labelOptions=marker.los) %>%
    addLegend(pal=pals, values=~value, opacity=.7, title=NULL, position='bottomright')
}

pretty.view(view.data)

pretty.view(
  data=view.data, 
  legend.cut=c(1,10,20,30,40,Inf), 
  map.provider=providers$CartoDB.Positron,
  palette.name='YlOrRd'
)

