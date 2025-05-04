################################################################################
# Pipeline for King County Election Results and Precinct Geometry

##### Preliminaries ############################################################
# Load Packages
suppressPackageStartupMessages(library(tidyverse))

# Parse Command Line Arguments
args = commandArgs(trailingOnly = TRUE)

df_i = paste0('data/raw/results/', args[1])
df_o = paste0('data/processed/results/processed_', args[1])

##### Functions: Election Results ##############################################
get_results = function(df) {
  # This function reads election results and subsets on relevant rows and 
  # columns.
  
  # Read Data
  df = read_csv(df, col_types = cols())
  
  # Add Year and Election
  df = df %>%
    mutate(
      year = args[2],
      election = args[3]
    )
  
  # Select and Rename Columns
  df = df %>%
    select(
      year,
      election,
      race = Race,
      precinct = Precinct,
      candidate = CounterType, 
      vote_count = SumOfCount)
  
  # Filter Rows
  df = df %>%
    filter(!candidate %in% c(
      'Registered Voters',
      'Times Counted',
      'Times Under Voted',
      'Times Over Voted'))
  
  df = df %>%
    mutate(precinct = str_squish(precinct)) %>%
    mutate(precinct = str_to_upper(precinct))
  
  df = df %>%
    mutate(candidate = gsub('\xf3', 'o', candidate, useBytes = TRUE)) %>%
    mutate(candidate = gsub('\xdf', 'a', candidate, useBytes = TRUE))
  
  print(paste('Done: get_results:', args[1]))
  
  return(df)
}

parse_jurisdiction_position = function(df, include, exclude, filter = TRUE) {
  # This function parses the `race` column to obtain values for the 
  # `jurisdiction` and `position` columns, including specified jurisdictions
  # and positions while dropping others.

  # Initialize Columns
  df = df %>%
    mutate(jurisdiction = NA) %>%
    mutate(position = NA)
  
  # Parse Race > Get Jurisdiction
  for(i in seq_along(include)) {
    df = df %>%
      mutate(jurisdiction = 
          ifelse(grepl(include[i], race), 
            include[i], jurisdiction)) 
  }
  
  # Parse Race > Exclude Positions
  for(i in seq_along(exclude)) {
    df = df %>%
      filter(!grepl(exclude[i], race))
  }
  
  # Parse Race > Get Position
  for(i in seq_along(include)) {
    df = df %>% 
      mutate(position = 
          ifelse(jurisdiction == include[i], 
            gsub(include[i], '', race), position)) %>% 
      mutate(position = str_trim(position))
  }
  
  # Filter to Included Jurisdiction and Position
  if(filter) {
    df = df %>%
      filter(!is.na(jurisdiction)) %>%
      filter(!is.na(position))
  }
  
  # Select and Order Columns
  df = df %>%
    select(
      year,
      election,
      jurisdiction,
      position,
      candidate,
      precinct,
      vote_count
    )
  
  print(paste('Done: parse_jurisdiction_position:', args[1]))
  
  return(df)
}

fix_position = function(df, positions = 1:10) {
  # This function removes repetition and extra whitespace from positions.
  
  df = df %>%
    mutate(position = str_replace(position, 
      'Metropolitan', ''))
  
  for(i in positions) {
    df = df %>%
      mutate(position = str_squish(position)) %>%
      mutate(position = str_replace(position, 
        paste0(' Council District No. ', i), ''))
  }

  print(paste('Done: fix_position:', args[1]))
    
  return(df)
}

calculate_vote_percent = function(df) {
  # This function calculates precinct-level election results.
  
  df = df %>%
    group_by(year, election, jurisdiction, position, precinct) %>%
    mutate(vote_percent = vote_count / sum(vote_count) * 100) %>%
    mutate(vote_percent = round(vote_percent, 2)) %>%
    ungroup()
  
  print(paste('Done: calculate_vote_percent:', args[1]))
  
  return(df)
}

write_results = function(df, file) {
 
  df %>%
    arrange(year, election, jurisdiction, position, candidate, precinct) %>%
    write_csv(file)
  
  print(paste('Done: write_results:', args[1]))
   
}

##### Set Arguments ############################################################
include = c(
  'City of Seattle',
  'King County',
  'Port of Seattle',
  'Seattle School District No. 1')

exclude = c(
  'Fire Protection District',
  'Water District',
  'Cemetery District',
  'Airport District',
  'Proposition',
  'Election'
)

##### Call Functions ###########################################################
# Process Election Results
df_i %>%
  get_results() %>%
  parse_jurisdiction_position(include = include, exclude = exclude) %>%
  fix_position() %>%
  calculate_vote_percent() %>%
  write_results(file = df_o)






