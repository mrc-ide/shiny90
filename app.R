#!/usr/bin/env Rscript
library(shiny)
library(shinyjs)
library(shinycssloaders)

# Server
source("src/server/model_outputs.R")
source("src/server/plots.R")
source("src/server/workingSet.R")
source("src/server/spectrumFiles.R")
source("src/server/plotInputs.R")
source("src/server/surveyAndProgramData.R")
source("src/server/modelRun.R")
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
options(shiny.maxRequestSize=30*1024^2)

addResourcePath('images', file.path('images'))
runApp("src", port=8080)