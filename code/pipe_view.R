################################################################################
# Pipeline for King County Election Results and Precinct Geometry

##### Preliminaries ############################################################
# Load Packages
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(sf))
suppressPackageStartupMessages(library(DBI))
suppressPackageStartupMessages(library(RPostgres))
suppressPackageStartupMessages(library(leaflet))

##### Functions ################################################################
connect_to_database = function() {
  # This function connects to the database, returning a connection object.
  
  config = config::get(file = 'config/config_pipe.yml')
  
  conn = dbConnect(
    drv      = RPostgres::Postgres(),
    host     = config$host,
    port     = config$port,
    dbname   = config$dbname,
    user     = config$user,
    password = config$password
  )
  
  print(paste0('Done: connect_to_database'))

  return(conn)
}

get_data_for_centroid_and_area = function(conn, query_file = 'code/pipe_view_query.sql') {
  
  query_text = read_file(query_file)

  df = st_read(dsn = conn, query = query_text)
  
  print(paste0('Done: get_data_for_centroid_and_area'))
  
  return(df)
}

calculate_centroid_and_area = function(df) {
  # Calculate the centroid and area of each position's geometry, which will
  # be passed to setView() in make_leaflet().
  
  sf_use_s2(FALSE)
  
  df = df %>%
    
    # Get 1 Row/Precinct/Position
    group_by(
      year, 
      election, 
      jurisdiction, 
      position, 
      precinct
    ) %>%
    
    slice_head() %>%
    
    # Aggregate Precincts by Position
    group_by(
      year,
      election,
      jurisdiction,
      position
    ) %>%
    
    summarise(.groups = 'keep') %>%
    
    # Calculate Centroid and Area
    mutate(centroid = st_centroid(geometry)) %>%
    mutate(area = as.numeric(round(st_area(geometry)))) %>%
    st_drop_geometry() %>%
  
    # Disaggregate Centroid
    mutate(lng = unlist(centroid)[1]) %>%
    mutate(lat = unlist(centroid)[2]) %>%
    select(-centroid)
  
  sf_use_s2(TRUE)
  
  print('Done: get_centroid_and_area')
  
  return(df)
}

load_in_postgres = function(df, table, conn, app_user = 'shiny_app_user') {
  # This function loads results into SQL database.
  
  st_write(df, dsn = conn, layer = table, delete_layer = TRUE)
  
  grant = paste0('GRANT SELECT ON ', table, ' TO ', app_user, ';')
  grant = dbSendQuery(conn, grant)
  dbClearResult(grant)
  
  print(paste0('Done: load_in_postgres: ', table))
}

##### Call Functions ###########################################################
suppressWarnings({

  df = connect_to_database() %>%
    get_data_for_centroid_and_area() %>%
    calculate_centroid_and_area() %>%
    load_in_postgres(
      table = 'position_centroid_area', 
      conn = conn
    )
  
  dbDisconnect(conn)

})

