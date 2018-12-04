#!/usr/bin/env Rscript
if (Sys.getenv("SHINY90_QUIET") == "TRUE") {
    con <- file(tempfile(), "w")
    sink(tempfile())
    sink(con, type = "message")
    on.exit({
        sink(NULL)
        sink(NULL, type = "message")
        close(con)
    })
}

source("src/helpers.R")

# Server (alphabetical)
source("src/server/data_tables.R")
source("src/server/model_outputs.R")
source("src/server/model_run.R")
source("src/server/plot_inputs.R")
source("src/server/save_and_load.R")
source("src/server/spectrum_files.R")
source("src/server/survey_and_program_data.R")
source("src/server/working_set.R")

# UI (alphabetical)
source("src/ui/digest_buttons.R")
source("src/ui/input_panels.R")
source("src/ui/main_view.R")
source("src/ui/modals.R")
source("src/ui/model_outputs_panel.R")
source("src/ui/advanced_panel.R")
source("src/ui/model_run_panel.R")
source("src/ui/navigation.R")
source("src/ui/shapes.R")
source("src/ui/spectrum_files_panel.R")
source("src/ui/ui_helpers.R")
source("src/ui/welcome_view.R")
source("src/ui/working_set_section.R")

options(shiny.autoreload = TRUE, shiny.autoreload.pattern = glob2rx("**/*.R"))
options(shiny.maxRequestSize = 60*1024^2)

shiny::addResourcePath('images', file.path('images'))
shiny::shinyAppDir("src")