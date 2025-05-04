################################################################################
##### King County Political Atlas: Functions ###################################

##### Query Data ###############################################################
query_data = function(input, config_file = 'config/config_app.yml', 
  query_file = 'code/query_results.sql') {    
  # This function queries data based on user input.
  
  # Prepare Database Connection
  config = config::get(file = config_file)
  
  conn = dbConnect(
    drv      = RPostgres::Postgres(),
    host     = config$host,
    port     = config$port,
    dbname   = config$dbname,
    user     = config$user,
    password = config$password
  )
  
  # Prepare Query
  # (Get User Input)
  input_list = list(
    year         = input$year,
    election     = input$election,
    jurisdiction = input$jurisdiction,
    position     = input$position,
    candidate    = input$candidate
  )
  
  # (Select Geometry)
  geometry_table = ifelse(
    input$year < 2022, 
    'precinct_geometry_2016',
    'precinct_geometry_2022'
  )
  
  # (Paramaterize the Query)
  query_text = read_file(query_file)
  query_text = gsub('\\?geometry_table', geometry_table, query_text)
  query_text = sqlInterpolate(conn, query_text, .dots = input_list)
      
  # Run Query
  st_read(
    dsn   = conn, 
    query = query_text,
    quiet = TRUE
  )
}

##### Make Leaflet #############################################################
make_leaflet = function(df, input, zoom = 11, minZoom = 9, bound = 0.5) {

  # (REPLACE)
  view = tibble(lng = -122.335167, lat = 47.608013)

  # Distinguish Percent and Count
  values = round(with(df, get( input$value )), 1)
  symbol = ifelse(input$value == 'vote_percent', '%', 'votes')
    
  # Set Map Options and Parameters
  options  = leafletOptions(minZoom = minZoom)
  bound    = bound
  palette  = colorNumeric('magma', values)
  lastname = word(input$candidate, -1)

  # Generate Base Map
  map = leaflet(options = options) %>%
    
    addProviderTiles(
      providers$CartoDB.PositronNoLabels
      ) %>%
    
    setView(
      lng  = view$lng, 
      lat  = view$lat, 
      zoom = zoom
      ) %>%
    
    setMaxBounds(
      lng1 = view$lng + bound,
      lat1 = view$lat + bound,
      lng2 = view$lng - bound,
      lat2 = view$lat - bound
      )
  
  # Add Election Results
  map = map %>%
    # Results
    addPolygons(
      data = df, 
      
      # Appearance: Fill
      fillColor = ~palette(values), 
      fillOpacity = 0.8,
      
      # Appearance: Borders
      color = 'black',
      weight = 1,
      
      # Add Labels
      popup = ~paste0('<b>', precinct, '</b><br/>', 
        lastname, ': ', values, ' ', symbol),
      
      # Add Highlighting
      highlight = highlightOptions(
        weight = 3, 
        bringToFront = TRUE
      )
    ) %>%
    
    # Legend
    addLegend(
      pal = palette,
      values = values,
      title = paste0(lastname, ' (', symbol, ')')
    ) %>%
    
    # Reset Map
    leaflet.extras::addResetMapButton()

  return(map)
}
