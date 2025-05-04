################################################################################
# Pipeline for King County Election Results and Precinct Geometry

##### Preliminaries ############################################################
# Load Packages
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(sf))
suppressPackageStartupMessages(library(DBI))
suppressPackageStartupMessages(library(RPostgres))

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

get_results = function(path = 'data/processed/results/') {
  # This function concatenates all election results in 
  # '/data/processed/results' directory, returning a
  # data frame.
  
  files = list.files(path)
  
  df = tibble()
  
  for(i in seq_along(files)) {
    tmp = read_csv(paste0(path, files[i]),
      col_types = cols())
    df = bind_rows(df, tmp)
  }
  
  print('Done: get_results')
  
  return(df)
}

get_geometry = function(shp) {
  # This function loads a shapefile and returns a data frame.
 
  df = st_read(paste0('data/processed/geometry/', shp), 
    quiet = TRUE)
  
  print('Done: get_geometry')
  
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

create_index = function(conn, query_file) {
  # This function creates a multi-column index in the precinct_result table.
  
  index = read_file(query_file)
  index = dbSendQuery(conn, index)
  dbClearResult(index)
  
  print(paste0('Done: create_index'))
}

##### Call Functions ###########################################################
conn = connect_to_database()

get_results() %>%
  load_in_postgres(
    table = 'precinct_result', 
    conn = conn
  )

create_index(
  conn = conn, 
  query_file = 'code/create_index.sql'
)

get_geometry('precincts_king_2016/precincts_king_2016.shp') %>%
  load_in_postgres(
    table = 'precinct_geometry_2016',
    conn = conn
  )

get_geometry('precincts_king_2022/precincts_king_2022.shp') %>%
  load_in_postgres(
    table = 'precinct_geometry_2022',
    conn = conn
  )

dbDisconnect(conn)

