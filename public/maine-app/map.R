# load libraries
library(leaflet)
library(tidyverse)
library(htmlwidgets)

# read data from googlesheet that is published to the web
maine <- read_csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vRIi2n-sBlNHVgMTV3AwxvqeYq5yy-4pbv0rl9mi2xGTobwupj7AvfXaV13c9xqnRwuPWXxYFVqYh6B/pub?gid=0&single=true&output=csv")

# make awesome icons 
  # use version 4 docs https://fontawesome.com/v4.7.0/
  # if a new category is added this is the only code that needs to be updated
  # adding the new marker to the icon list will automatically add it to the map
maine_icons <- awesomeIconList(
  drink = makeAwesomeIcon(icon = "beer", library = "fa", markerColor = "beige"),
  eat   = makeAwesomeIcon(icon = "cutlery", library = "fa", markerColor = "lightred"),
  camp  = makeAwesomeIcon(icon = "fire", library = "fa", markerColor = "green"),
  see   = makeAwesomeIcon(icon = "eye", library = "fa", markerColor = "blue"),
  learn = makeAwesomeIcon(icon = "graduation-cap", library = "fa", markerColor = "purple"),
  shop  = makeAwesomeIcon(icon = "shopping-cart", library = "fa", markerColor = "orange")
)

# make popup text with name, address, notes, and link to website
maine <-
  maine %>% 
  mutate(popup = paste("<b><a href='", link,"'>", name,"</a></b>", "<br/>",
                       address, ', ', city, "<br/>", sep=''))


# create leaflet map

# setup basemap
m <- 
  leaflet() %>% 
  addTiles()

# add one overlay layer for each marker in maine_icons using purrr
# use walk from per to return m after adding each layer
names(maine_icons) %>%                     # get names of markers in awesomeIconList
  walk(function(x)                         # then walk through vector of names one at a time
    m <<- 
      m %>% addAwesomeMarkers(             # creating a new awesome marker layer  
      data = filter(maine, category == x), # for each category in the maine data
      group = x,                           
      icon = maine_icons[[x]],
      popup = ~popup))

# add layer controls to map 
m <- 
  m %>% 
  addLayersControl(
    overlayGroups = names(maine_icons),
    options = layersControlOptions(collapsed = TRUE)
  )

# save widget 
saveWidget(m, "maine_map.html")
