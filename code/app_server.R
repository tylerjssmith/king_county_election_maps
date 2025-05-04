################################################################################
##### King County Political Atlas: Server ######################################

##### Server ###################################################################
server = function(input, output) {

  ##### Dynamic User Input #####################################################
  # (For year, filter and get elections.)
  year = reactive({
    ui_options %>% filter(year == input$year)
  })
  
  observeEvent(year(), {
    choices = sort(unique(year()$election))
    updateSelectInput(inputId = 'election', choices = choices)
  })  

  # (For election, filter and get jurisdictions)
  election = reactive({
    year() %>% filter(election == input$election)
  })
  
  observeEvent(election(), {
    choices = sort(unique(election()$jurisdiction))
    updateSelectInput(inputId = 'jurisdiction', choices = choices)
  })

  # (For jurisdiction, filter and get positions.)
  jurisdiction = reactive({
    election() %>% filter(jurisdiction == input$jurisdiction)
  })
  
  observeEvent(jurisdiction(), {
    choices = sort(unique(jurisdiction()$position))
    updateSelectInput(inputId = 'position', choices = choices)
  })

  # (For position, filter and get candidates.)
  position = reactive({
    jurisdiction() %>% filter(position == input$position)
  })
  
  observeEvent(position(), {
    choices = sort(unique(position()$candidate))
    updateSelectInput(inputId = 'candidate', choices = choices)
  })

  # (For candidate, filter.)
  candidate = reactive({
    position() %>% filter(candidate == input$candidate)
  })
  
  ##### Query Data #############################################################
  df = eventReactive(input$run, {

    query_data(input = input)    

  })
  
  ##### Make Leaflet ###########################################################
  data <- reactiveValues()
  
  observeEvent(input$run, {
    
    data$map <- make_leaflet(df = df(), input = input)
    
  })

  output$map = renderLeaflet({
    
    data$map

  })
  
}