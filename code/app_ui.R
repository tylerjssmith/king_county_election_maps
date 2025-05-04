################################################################################
##### King County Political Atlas: User Input ##################################

##### Header ###################################################################
header = dashboardHeader(
  title = 'King County Political Atlas',
  titleWidth = 300
)

##### Sidebar ##################################################################
sidebar = dashboardSidebar(
  width = 300,
  
  sidebarMenu(
    
    menuItem(
      'Select Result',
      startExpanded = TRUE,
      
      selectInput(
        inputId = 'year',
        label = 'Year',
        choices = paste0(c('', sort(unique(ui_options$year)))),
        selected = '',
      ),
      
      selectInput(
        inputId = 'election',
        label = 'Election',
        choices = NULL
      ),
      
      selectInput(
        inputId = 'jurisdiction',
        label = 'Jurisdiction',
        choices = NULL
      ),
      
      selectInput(
        inputId = 'position',
        label = 'Position',
        choices = NULL
      ),
      
      selectInput(
        inputId = 'candidate',
        label = 'Candidate',
        choices = NULL
      ),
      
      radioButtons(
        inputId = 'value',
        label = 'Value',
        choiceNames = c(
          'Percentage',
          'Count'
        ),
        choiceValues = c(
          'vote_percent',
          'vote_count'
        )
      ),
      
      actionButton(
        inputId = 'run',
        label = 'Run'
      )
    )
  )
)

##### Body #####################################################################
body = dashboardBody(
  
  leafletOutput(
    outputId = 'map', 
    width = '100%',
    height = 800
  )
)

##### User Input ###############################################################
ui = dashboardPage(header, sidebar, body)