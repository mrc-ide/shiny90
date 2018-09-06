#!/usr/bin/env Rscript
library(shiny)
library(shinyjs)
library(shinycssloaders)

source("src/helpers.R")

# Server
source("src/server/model_outputs.R")
source("src/server/plots.R")
source("src/server/workingSet.R")
source("src/server/spectrumFiles.R")
source("src/server/plotInputs.R")
source("src/server/surveyAndProgramData.R")
source("src/server/modelRun.R")
source("src/server/save_and_load.R")
source("src/server.R")

# UI
source("src/ui/ui_helpers.R")
source("src/ui/shapes.R")
source("src/ui/main_view.R")
source("src/ui/digest_buttons.R")
source("src/ui/working_set_section.R")
source("src/ui/welcome_view.R")
source("src/ui/modals.R")
source("src/ui/navigation.R")
source("src/ui/spectrum_files_panel.R")
source("src/ui/input_panels.R")
source("src/ui/model_run_panel.R")
source("src/ui/model_outputs_panel.R")

options(shiny.autoreload=TRUE, shiny.autoreload.pattern = glob2rx("**/*.R"))
options(shiny.maxRequestSize=30*1024^2)

addResourcePath('images', file.path('images'))
runApp("src", port=8080)