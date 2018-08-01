# server - maine map app
# 7/26/2018

function(input, output){ 
  
  # source geocoding script to geocode any new locations to googlesheet  
  source("geocode_locations.R")
  
  # make popup text with name, address, notes, and link to website
  maine <-
    maine %>% 
    mutate(popup = paste("<b><a href='", link,"'>", name,"</a></b>", "<br/>",
                         address, ', ', city, "<br/>", sep=''))
  
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
  
}