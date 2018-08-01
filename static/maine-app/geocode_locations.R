# load maine places data from googlesheets 
  # helpful examples: https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples
  # sheet url: https://docs.google.com/spreadsheets/d/1E9ARIwEj76Atp_kbYziGAWNAyLK82tO_Ad5IdRMjpWE/edit#gid=0
  # published sheet: https://docs.google.com/spreadsheets/d/e/2PACX-1vRIi2n-sBlNHVgMTV3AwxvqeYq5yy-4pbv0rl9mi2xGTobwupj7AvfXaV13c9xqnRwuPWXxYFVqYh6B/pubhtml  

maine_sheet <- gs_key("1E9ARIwEj76Atp_kbYziGAWNAyLK82tO_Ad5IdRMjpWE", 
                      lookup = FALSE,
                      visibility = "private") # see: https://stackoverflow.com/questions/32537882/adding-rows-to-a-google-sheet-using-the-r-package-googlesheets

# read maine place data into a dataframe 
maine <- gs_read(maine_sheet) 

# create df of locations without lat/lon
new_locations <- 
  maine %>% 
  filter(is.na(lon)) %>% 
  mutate(location = paste(address, city, "Maine", sep = ", ")) %>% 
  select(-lon, -lat) 

# if there are new locations (i.e. non-geocoded locations) geocode them 
# then combine back with previously geocoded locations
# and replace exisiting data in google sheet
if(nrow(new_locations) > 0){
# geocode new locations 
new_locations <- 
  new_locations %>%
  select(location) %>% 
  map_df(~geocode(., override_limit = TRUE)) %>% 
  bind_cols(new_locations, .) %>% 
  select(-location)

# create df of locations with lat/lon 
old_locations <- 
  maine %>% 
  filter(!is.na(lon))

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
}