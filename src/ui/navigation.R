navigationPanel <- function() {
    shiny::navlistPanel(well = FALSE, widths = c(2, 10),
        panelWithTitle("Upload spectrum file(s)", panelSpectrum()),
        panelWithTitle("Upload survey data", panelSurvey()),
        panelWithTitle("Upload programmatic data", panelProgram()),
        panelWithTitle("Review input data", panelReviewInput()),
        panelWithTitle("Run model", panelModelRun()),
        panelWithTitle("Advanced outputs", panelAdvanced())
    )
}

panelWithTitle <- function(title, content) {
    shiny::tabPanel(title, div("",
        shiny::h1(title, class = "panelTitle"),
        content
    ))
}

# Server side
enableNavLinks <- function(input, output, spectrumFilesState, modelRunState, surveyAndProgramData) {
    enableTabWhen("Upload survey data", function() { spectrumFilesState$anyDataSets() })
    enableTabWhen("Upload programmatic data", function() { spectrumFilesState$anyDataSets() })
    enableTabWhen("Review input data", function() { spectrumFilesState$anyDataSets() &&
                                                    surveyAndProgramData$anyProgramData() })
    enableTabWhen("Run model", function() { spectrumFilesState$anyDataSets() &&
                                            surveyAndProgramData$anyProgramData() &&
                                            surveyAndProgramData$programDataValid() &&
                                            surveyAndProgramData$surveyDataValid()})
    enableTabWhen("Advanced outputs", function() { modelRunState$state == "converged" &&
                                                    spectrumFilesState$anyDataSets() &&
                                                    surveyAndProgramData$anyProgramData() &&
                                                    surveyAndProgramData$programDataValid() &&
                                                    surveyAndProgramData$surveyDataValid()})
}

enableTabWhen <- function(tabTitle, condition) {
    shinyjs::js$disableTab(tabTitle)
    shiny::observe({
        if (condition()) {
            shinyjs::js$enableTab(tabTitle)
        } else {
            shinyjs::js$disableTab(tabTitle)
        }
    })
}