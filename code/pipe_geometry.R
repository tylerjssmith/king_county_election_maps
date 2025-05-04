################################################################################
# Pipeline for King County Election Results and Precinct Geometry

##### Preliminaries ############################################################
# Load Packages
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(sf))

# Parse Command Line Arguments
args = commandArgs(trailingOnly = TRUE)

file_in  = paste0('data/raw/geometry/', args[1])
file_out = paste0('data/processed/geometry/', args[2])

##### Functions: Precinct Geometry #############################################
get_geometry = function(shp) {
  # This function reads the shapefile with precinct boundaries and subsets
  # on relevant columns.
  
  # Read Data
  shp = st_read(shp, quiet = TRUE)
  
  # Transform Data
  shp = shp %>%
    st_transform(4326)
  
  # Select and Rename Columns
  shp = shp %>%
    select(
      precinct = NAME,
      geometry
    )
  
  shp = shp %>%
    mutate(precinct = str_squish(precinct)) %>%
    mutate(precinct = str_to_upper(precinct))
  
  print(paste('Done: get_geometry:', args[1]))
  
  return(shp)
}

write_geometry = function(shp, dsn) {
 
  shp %>% 
    arrange(precinct) %>%
    write_sf(dsn = file_out)
  
  print(paste('Done: write_geometry:', args[1]))  
   
}

##### Call Functions ###########################################################
file_in %>%
  get_geometry() %>%
  write_geometry(dsn = file_out)

