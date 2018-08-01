---
output: html_document
---





```r
library(leaflet)
library(tidyverse)

# insert your leaflet url from Mapbox here.
my_map_tile <- "your leaflet url goes here inside quotes"
```




```r
# read in ipeds data on all four-year colleges
colleges <- read_csv("https://raw.githubusercontent.com/majerus/NEDRA2018/master/four_year_colleges_2017.csv")

# add colleges to our map!
colleges %>% 
  leaflet() %>% 
    addTiles(urlTemplate = my_map_tile) %>% 
    setView(lng = -98.6 , lat = 39.8, zoom = 2) %>% 
    addCircles(label = ~name, color = "#3c7e61")
```

preservee294951d0bc085c0





