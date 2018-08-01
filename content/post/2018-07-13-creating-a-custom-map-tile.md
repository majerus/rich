---
title: Creating a Custom Map Tile
author: Rich
date: '2018-07-13'
slug: creating-a-custom-map-tile
categories:
  - R
tags:
  - leaflet
  - maps
  - R
  - mapbox
---

In my [DataCamp](https://www.datacamp.com/courses/interactive-maps-with-leaflet-in-r) course on making interactive web maps in R using leaflet, I covered how to change the map tile using the `addProviderTiles` function. This allows us to use the more than 100 map tiles included with the `leaflet` package. For example, we can create a map using the Esri provider tile. 

<iframe width="100%" height = 650 src="/rmarkdown-files/leaflet_Esri.html" frameborder="0" allowfullscreen></iframe>

However, there may come a time when we need to customize a map beyond using these provider tiles so that it fits with a particular project or website.  One way to accomplish this is to use [Mapbox](www.mapbox.com). What follows is a quick overview that demostrates how to access and build custom maptiles in R, for more information see the [Mapbox tutorials](https://www.mapbox.com/help/tutorials/). 


Once we create an account on Mapbox, we will have access to their [design studio](https://www.mapbox.com/studio/) that enables point-and-click editting of map layers, colors, icons, fonts, etc. Currently, Mapbox provides 50,000 map views a month for free (see [pricing](https://www.mapbox.com/pricing/)). 

In the design studio we can start with the basic template or select one of the core styles that may approximate the look that we are going for.  
  
<br><br>

<img src="/img/design_studio.png" width="100%">
  
<br><br>

For this example, I'll be working with the Decimal map template. Once we select a map style the editor will open and we will see the map, the map layers presented in the left-hand sidebar, and some additional functionality presented in the upper-right corner menu (e.g., adding images, fonts, etc.).   

<br><br>

<img src="/img/decimal.png" width="100%">

<br><br>

We can edit the layers individually or we can edit the several layers of the same type at the same time by selecting multiple layers while holding shift. 

<br><br>

<img src="/img/decimal_layers.png" width="100%">

<br><br>

For example, we could change the color of the lines from green to blue (i.e., `#002787`).

<img src="/img/decimal_change_color.png" width="100%">

<br><br>

We can also include stops at different zoom levels so that the colors of certain layers of our map transition as we zoom.  

<br><br>

<img src="/img/mapbox_color.gif" width="100%">

<br><br>

Once we have our map styled, we can use it from R by clicking publish in the upper-right corner menu.

<img src="/img/publish.png" width="100%">

After we publish our map, we can click share and scroll to the "Develop with this Style box". Then switch the slider from Mapbox to leaflet and copy the link. We can access our new map from R using the `urlTemplate` argument of the `addTiles` function. Zoom in to check out those blue lines!


<iframe width="100%" height = 750 src="/rmarkdown-files/leaflet_urlTemplate.html" frameborder="0" allowfullscreen></iframe>

Then we can add markers or other features using the functions from the `leaflet` package. 

<iframe width="100%" height = 850 src="/rmarkdown-files/addMarkers.html" frameborder="0" allowfullscreen></iframe>

Give it a try and let me know what you create!
