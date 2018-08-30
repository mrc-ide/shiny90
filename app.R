#!/usr/bin/env Rscript
library(shiny)
library(shinycssloaders)

# Server
source("src/server.R")

# UI
source("src/forms.R")
source("src/shapes.R")
source("src/main_view.R")
source("src/welcome_view.R")
source("src/navigation.R")
source("src/panels/input_panels.R")
source("src/panels/model_run_panel.R")
source("src/panels/model_outputs_panel.R")

options(shiny.autoreload=TRUE, shiny.autoreload.pattern = glob2rx("**/*.R"))
addResourcePath('images', file.path('images'))
runApp("src", port=8080)