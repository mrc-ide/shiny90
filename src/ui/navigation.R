navigationPanel <- function() {
    shiny::navlistPanel(well = FALSE, widths = c(2, 10),
        panelWithTitle("Upload spectrum file(s)", panelSpectrum()),
        panelWithTitle("Upload survey data", panelSurvey()),
        panelWithTitle("Upload programmatic data", panelProgram()),
        panelWithTitle("Review input data", panelReviewInput()),
        panelWithTitle("Run model", panelModelRun()),
        panelWithTitle("View model outputs", panelModelOutputs())
    )
}

panelWithTitle <- function(title, content) {
    shiny::tabPanel(title, div("",
        shiny::h1(title),
        content
    ))
}

# Server side
enableNavLinks <- function(input, output, spectrumFilesState, modelRunState, surveyAndProgramData) {
    enableTabWhen("Upload survey data", function() { spectrumFilesState$anyDataSets() })
    enableTabWhen("Upload programmatic data", function() { spectrumFilesState$anyDataSets() })
    enableTabWhen("Review input data", function() { spectrumFilesState$anyDataSets() && surveyAndProgramData$anyProgramData() })
    enableTabWhen("Run model", function() { spectrumFilesState$anyDataSets() && surveyAndProgramData$anyProgramData() })
    enableTabWhen("View model outputs", function() {
        spectrumFilesState$anyDataSets() && modelRunState$state == "finished"
    })
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