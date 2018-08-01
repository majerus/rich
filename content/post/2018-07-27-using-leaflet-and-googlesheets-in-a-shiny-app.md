---
title: 'Using Leaflet and Googlesheets in a Shiny App '
author: Rich
date: '2018-07-27'
slug: using-leaflet-and-googlesheets-in-a-shiny-app
categories:
  - R
tags:
  - leaflet
  - maps
  - R
  - mapbox
---

Building on the [Making a Maine Map with purrr to Add Multiple Layers](http://richmajerus.com/post/my-maine-map/) blog post, this week I worked to deploy a map of my favorite places in Maine as a [shiny app](https://rich.shinyapps.io/maine-map/). There are a couple of advantages to this approach: 

- New favorites that I add to my [googlesheet](https://docs.google.com/spreadsheets/d/1E9ARIwEj76Atp_kbYziGAWNAyLK82tO_Ad5IdRMjpWE/edit?usp=sharing) will be automatically geocoded and added to the map
- I can add a table that is linked to the map (i.e., will display the names and locations of all of the locations visible on map).

The [app](https://rich.shinyapps.io/maine-map/) is hosted on shinyapps.io (thanks RStudio) and the [code](https://github.com/majerus/rich/tree/master/static/maine-app) is available on github. I've tried to highlight a few features of the app in more depth below, so keep reading after checking out a few of my Maine favorites. 

<iframe width="100%" height = 1000 src="https://rich.shinyapps.io/maine-map/" frameborder="0" allowfullscreen></iframe>


## Loading data from a googlesheet in a shiny app

Every time the app is loaded in a web browser shiny checks for locations that do not have lat/lon coordinates. If there are any missing coordinates these locations are geocoded using `ggmap::geocode`. If there were a lot of data it would be inefficient to reload all of the locations each time a web browser is refreshed, but given the small number of points (currently ~30) this was an easy trade-off to have new locations quickly and easily geocoded when the app is refreshed. The app works this way because the call to the geocoding script is inside the server function in the `server.r` file. To load the data only when the app is first initialized, we could move `source("geocode_locations.R")` above `function(input, output)` or to the `global.r` file. 

```
# server - maine map app

function(input, output){ 
  
  # source geocoding script to geocode any new locations to googlesheet  
  source("geocode_locations.R")
  ...
}
```

To enable the deployed app to read the googlesheet, I chose to include the `oauth` file that is created by the `googlesheets` package when I pushed the app to shinyapps.io. Jenny Bryan and Dean Attali have several helpful examples of how the `googlesheets` package can be used in shiny apps [here](https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples).


## Deploying a leaflet map in a shiny app 

To create the leaflet map in shiny, we use the `renderLeaflet` function in the `server.r` file and the `leafletOutput` function in the `ui.r` file to display the map to our app's users. Inside the `renderLeaflet` function we can build our leaflet map similar to how we would in an r script or rmarkdown document.  

```
 # create leaflet map output
  output$maine_map <- renderLeaflet({
    
    # clear markers 
    # the m leaflet object is created in global.r 
    # markers are cleared on refresh so new locations can be added
    m <- 
      m %>% 
      clearMarkers()
    
    # add one overlay layer for each marker in maine_icons using purrr
    # use walk from per to return m after adding each layer
    input$location_types %>%                     # get names of markers in awesomeIconList
      walk(function(x)                         # then walk through vector of names one at a time
        m <<- 
          m %>% addAwesomeMarkers(             # creating a new awesome marker layer  
            data = filter(maine, category == x), # for each category in the maine data
            group = x,                           
            icon = maine_icons[[x]],
            popup = ~popup))
    
    m
  })
```

In this approach, we need to use `clearmarkers()` so that our markers are (re)added to the map every time a user changes the categories selected in the sidebar menu. Otherwise, when our markers are added by walking over the categories of markers a user selects ( `input$location_types %>% walk(function(x)...`) more markers would just be added on top of the existing markers and no markers would be removed. There are alternative approaches to building this map in shiny, but I liked the idea of continuing to build my knowledge and familiarity of the `purrr` package. 

## Using a leaflet map as a filter in a shiny app

A handy trick I learned from RStudio's [super zip example](https://shiny.rstudio.com/gallery/superzip-example.html) is to have a leaflet map work both as a data visualization and a filter for data displayed in a table. The data displayed in the table will be automatically filtered as a user zooms and pans the map so that the table only displays the observations that are visible on the map.

All of the magic for this can happen inside the `DT::renderDataTable` function in the `server.r` file. First we need to capture the current map bounds and find the highest and lowest values for both lat and lon. Then we can use these values as filters in a `dplyr` function chain to limit our data to only the observations with coordinates that are within the lat and lon ranges visible on the map. 

```
  # create data table of locations that are visible on the map
  output$maine_table <- DT::renderDataTable({
    
    # get current bounds of map
    bounds <- input$maine_map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    maine %>% 
      # apply type filter from sidebar
      filter(category %in% input$location_types) %>% 
      # apply map filters
      filter(lon >= lngRng[1],
             lon <= lngRng[2],
             lat >= latRng[1],
             lat <= latRng[2]) %>% 
      select(name, category, address, city)
  }, rownames = FALSE) # because rownames :(
```

Take a shot at deploying one of your interactive maps as a shinyapp. You can create an account on [shinyapps.io](http://www.shinyapps.io/) and host up to five applications for free. 

