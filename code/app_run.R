################################################################################
##### King County Political Atlas: Run #########################################

##### Preliminaries ############################################################
# Load Packages
library(tidyverse)
library(shiny)
library(shinydashboard)
library(DBI)
library(RPostgres)
library(sf)
library(leaflet)
library(leaflet.extras)

# Load Look-up Table
ui_options = read_csv('data/processed/input/ui_options.csv')

# Load Functions
source('code/app_functions.R')
source('code/app_ui.R')
source('code/app_server.R')

##### Run App ##################################################################
shinyApp(ui, server)
