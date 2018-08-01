# global - maine map app
# 7/26/2018

# load libraries
library(shinydashboard)
library(shiny)
library(googlesheets)
library(tidyverse)
library(ggmap)
library(leaflet)

# make icons for categories listed in googlesheet
maine_icons <- awesomeIconList(
  drink = makeAwesomeIcon(icon = "beer", library = "fa", markerColor = "beige"),
  eat   = makeAwesomeIcon(icon = "cutlery", library = "fa", markerColor = "lightred"),
  camp  = makeAwesomeIcon(icon = "fire", library = "fa", markerColor = "green"),
  see   = makeAwesomeIcon(icon = "eye", library = "fa", markerColor = "blue"),
  learn = makeAwesomeIcon(icon = "graduation-cap", library = "fa", markerColor = "purple"),
  shop  = makeAwesomeIcon(icon = "shopping-cart", library = "fa", markerColor = "orange")
)

# setup basemap
m <- 
  leaflet() %>% 
  addTiles()