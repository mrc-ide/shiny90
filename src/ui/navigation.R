library(shiny)
library(shinyjs)

navigationPanel <- function() {
    navlistPanel(well = FALSE, widths = c(2, 10),
        panelWithTitle("Upload spectrum file(s)", panelSpectrum()),
        panelWithTitle("Upload survey data", panelSurvey()),
        panelWithTitle("Upload programmatic data", panelProgram()),
        panelWithTitle("Review input data", panelReviewInput()),
        panelWithTitle("Run model", panelModelRun()),
        panelWithTitle("View model outputs", panelModelOutputs())
    )
}

panelWithTitle <- function(title, content) {
    tabPanel(title, div("",
        h1(title),
        content
    ))
}

# Server side
enableNavLinks <- function(input, output, spectrumFilesState, modelRunState) {
    enableTabWhen("Upload survey data", function() { spectrumFilesState$anyDataSets() })
    enableTabWhen("Upload programmatic data", function() { spectrumFilesState$anyDataSets() })
    enableTabWhen("Review input data", function() { spectrumFilesState$anyDataSets() })
    enableTabWhen("Run model", function() { spectrumFilesState$anyDataSets() })
    enableTabWhen("View model outputs", function() {
        spectrumFilesState$anyDataSets() && modelRunState$state == "finished"
    })
}

enableTabWhen <- function(tabTitle, condition) {
    js$disableTab(tabTitle)
    observe({
        if (condition()) {
            js$enableTab(tabTitle)
        } else {
            js$disableTab(tabTitle)
        }
    })
}