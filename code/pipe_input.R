################################################################################
# Pipeline for King County Election Results and Precinct Geometry

##### Preliminaries ############################################################
# Load Packages
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(DBI))
suppressPackageStartupMessages(library(RPostgres))

##### Functions ################################################################
get_results = function(config_file = 'config/config_pipe.yml') {
  # This function obtains all current results to parse for user input
  # options.
  
  config = config::get(file = config_file)
  
  conn = dbConnect(
    drv      = RPostgres::Postgres(),
    host     = config$host,
    port     = config$port,
    dbname   = config$dbname,
    user     = config$user,
    password = config$password
  )
  
  df = dbGetQuery(conn, 'SELECT * FROM precinct_result;')
  
  dbDisconnect(conn)

  print('Done: get_results')
  
  return(df)
}

parse_results_for_input_options = function(df) {
  # This function parses results for user input options.

  df = df %>%
      group_by(
        year, 
        election, 
        jurisdiction, 
        position) %>%
      count(candidate) %>%
      select(-n)

  print('Done: parse_results_for_input_options')
    
  return(df)
}

write_input_options = function(df, file) {
  
  df %>%
    write_csv(file)
  
  print('Done: write_input')
  
}

##### Call Functions ###########################################################
get_results() %>%
  parse_results_for_input_options() %>%
  write_input_options(file = 'data/processed/input/ui_options.csv')
