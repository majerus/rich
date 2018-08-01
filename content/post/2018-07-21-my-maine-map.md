---
title: 'Making a Maine Map with purrr to Add Multiple Layers'
author: Rich
date: '2018-07-21'
slug: my-maine-map
categories:
  - R
tags:
  - leaflet
  - maps
  - R
---

This week I went backcountry camping with Brooke at Cutler Public Land Preserve on Maine's northern coast. Mainers call this area the bold coast for its dramatic cliffs, which was certainly the case at our campsite pictured below. 

<img src="/img/cutler.JPG" width="100%"> 

I've hiked Cutler before but forgot how awesome and awe-inspiring the landscape is. While we were hiking out we started talking about other places in Maine that we've visited and would like to go back to. It seems like whenever anyone comes to visit (which seems like every weekend in July and never in February...), we can't remember all of the great places Maine has to offer us and our friends. 

To help me remember our Maine favorites, I created a leaflet map that categorizes our favorite places to camp, eat, drink, learn, shop, and sight-see. 

<iframe width="100%" height = 750 src="/rmarkdown-files/maine_map.html" frameborder="0" allowfullscreen></iframe>

The markers are added in seperate layers using the `purrr` package, so we don't have to call `addAwesomeMarkers` a bunch of times and to make it easier to add new categories and more favorites later. Each type of marker can be toggled on and off using the menu in the upper right corner and clicking on a marker reveals a popup with more information about the location. 
The data for the map lives in a [googlesheet] (https://docs.google.com/spreadsheets/d/1E9ARIwEj76Atp_kbYziGAWNAyLK82tO_Ad5IdRMjpWE/edit#gid=0) and I wrote an R script to geocode new locations that are added to the sheet. 

## Geocoding Our Maine Favorites

After loading the libraries, we use the `googlesheets` package to read the data into R. The sheet key used to locate the sheet in the `gs_key` function is available in the sheet's url. 

```
# load libraries 
library(googlesheets)
library(tidyverse)
library(ggmap)

# load maine places data from googlesheets 
maine_sheet <- gs_key("1E9ARIwEj76Atp_kbYziGAWNAyLK82tO_Ad5IdRMjpWE", 
                      lookup = FALSE,
                      visibility = "private") 
    
# read maine place data into a dataframe 
maine <- gs_read(maine_sheet) 

```

Then we split the data into new and old locations (i.e., those that have coordinates and those that do not.).

```
# create df of locations without lat/lon
new_locations <- 
  maine %>% 
  filter(is.na(lon)) %>% 
  mutate(location = paste(address, city, "Maine", sep = ", ")) %>% 
  select(-lon, -lat) 

# create df of locations with lat/lon 
old_locations <- 
  maine %>% 
  filter(!is.na(lon))

```

Leaving the old locations alone, we geocode all of the new locations. To return a geocoded data frame  in one fell swoop we use the `map_df` function from the `purrr` package to iterate the `geocode` function from the `ggmaps` package over each row in the `new_locations` data frame. 

```
# geocode new locations 
new_locations <- 
  new_locations %>%
  select(location) %>% 
  # geocode each location in new_locations
  map_df(~geocode(., override_limit = TRUE)) %>% 
  # bind lon and lat onto new_locations
  bind_cols(new_locations, .) %>% 
  # drop location variable created for geocoding
  select(-location)
```

Then we reunite the new and old locations and write the new data back to the same googlesheet using the `gs_edit_cells` function from the `googlesheets` package. 

```
# combine new and old locations 
maine <- 
  new_locations %>% 
  bind_rows(old_locations)

# write data with new lat/lon to googlesheet
gs_edit_cells(ss = maine_sheet, 
              ws = "Maine", 
              input = maine, 
              anchor = "A1",
              trim = TRUE,
              col_names = TRUE)
```

## Mapping Our Maine Favorites


We could use the same approach from the `googlesheets` package to read our data into R to create a map, but I chose a simpler alternative - publishing the sheet to the web as a .csv and loading the data into R using the `read_csv` function. The published .csv will update wheneve the googlesheet is changed so this approach should always use the most recent data. To publish a googlesheet to the web, click on the file menu and select publish to the web (note: this is different than publicly sharing your googlehseet.)

<img src="/img/gs_publish1.png" width="100%"> 

Then we can load our data just like any other .csv file.

```
# read data from googlesheet that is published to the web
maine <- read_csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vRIi2n-sBlNHVgMTV3AwxvqeYq5yy-4pbv0rl9mi2xGTobwupj7AvfXaV13c9xqnRwuPWXxYFVqYh6B/pub?gid=0&single=true&output=csv")

```

Then we select a font awesome icon for each category of favorites included in the data. Because we use `purrr` later to add the markers this is the only section of the code that would need to be updated if new categories are added to the data. 

```
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

```

One more step before the heavy lifting, let's add a popup variable that links to the webiste of each of the locations. 

```
# make popup text with name, address, notes, and link to website
maine <-
  maine %>% 
  mutate(popup = paste("<b><a href='", link,"'>", name,"</a></b>", "<br/>",
                       address, ', ', city, "<br/>", sep=''))
```

Now we're ready to make our map. First, we set up our base map and store it in an object called `m`. 

```
m <- 
  leaflet() %>% 
  addTiles()
```

Then we add one layer to our map for each type of marker in `maine_icons`, so as of now we are adding six layers (i.e., camp, drink, eat, learn, shop, and see). To do this without `purrr` we would have to call `addAwesomeMarkers` six times and would have to remember to add another call to `addAwesomeMarkers` whenever we added a new type of marker to `maine_icons`. With the `walk` function from `purrr` we can add all of these layers to `m` in one go.  It took me a little while to figure out how to use `walk` to accomplish this, but I think the payoff going forward is clear as adding to the map will be much easier going forward. 

```
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
```

Finally, we add layer controls to `m` and save our map. 

```
# add layer controls to map 
m <- 
  m %>% 
  addLayersControl(
    overlayGroups = names(maine_icons),
    options = layersControlOptions(collapsed = TRUE)
  )

# save widget 
saveWidget(m, "/rmarkdown-files/maine_map.html")

```

I hope you enjoy checking out a few of our favorite places in Maine and feel free to send suggestions my way. 

The full [geocoding](/maine-app/geocode_locations.R) and [mapping](/maine-app/map.R) R scripts are available in the github repo for my personal website. 

My goal for next week is to set this up in a shiny app so that new locations added to the googlesheet are automatically geocoded without having to run the `geocode_locations.R` script and to demonstrate how to deploy leaflet maps in shiny with a few enhanced user features. 



