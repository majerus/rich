# ui - maine map app
# 7/26/2018

# create shinydashboard page
dashboardPage(
  
  # dashboard header
  dashboardHeader(title = "Maine Map"),
  
  # dashboard sidebar
  dashboardSidebar(
    # allow user to select multiple categories of location
    selectInput("location_types", 
                "Location Types",
                choices = names(maine_icons),
                selected = names(maine_icons),
                multiple = TRUE)
  ),
  
  # dashboard body
  dashboardBody(
    
    # map
    fluidRow(
      box(
        width = 12, 
        title = "Favorite Locations Map", 
        status = "primary", 
        solidHeader = TRUE,
        collapsible = TRUE,
        leafletOutput("maine_map")
      )
    ),
    
    # data table
    fluidRow(
      box(
        width = 12, 
        title = "Favorite Locations Table",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        DT::dataTableOutput("maine_table")
      )
    ))
)