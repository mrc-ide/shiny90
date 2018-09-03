library(shiny)
library(shinyjs)

navigationPanel <- function() {
    navlistPanel(well=FALSE, widths=c(2, 10),
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
enableNavLinks <- function(input, output, spectrumFilesState) {
    js$disableTab("Review input data")
    observe({
        if (spectrumFilesState$anySpectrumFiles()) {
            js$enableTab("Review input data")
        } else {
            js$disableTab("Review input data")
        }
    })
}