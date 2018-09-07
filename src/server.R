library(shiny)

server <- function(input, output, session) {
    # State
    workingSet <- reactiveValues()
    workingSet$name <- NULL
    workingSet$notes <- NULL
    workingSet$creation_error <- NULL
    workingSet$editing <- FALSE

    surveyAndProgramData <- reactiveValues()
    surveyAndProgramData$survey <- NULL
    surveyAndProgramData$program <- NULL

    spectrumFilesState <- reactiveValues()
    spectrumFilesState$dataSets <- list()

    # Logic
    loadState <- handleLoad(input, workingSet, surveyAndProgramData, spectrumFilesState)
    workingSet <- workingSetLogic(input, output, session, loadState$workingSet)

    spectrumFilesState <- spectrumFiles(input, output, loadState$spectrumFilesState)
    surveyAndProgramData <- surveyAndProgramData(input, output, loadState$surveyAndProgramData)
    plotInputs(output, surveyAndProgramData)
    modelRunState <- modelRun(input, output, spectrumFilesState, surveyAndProgramData)

    handleSave(input, output, workingSet, spectrumFilesState, surveyAndProgramData)
    enableNavLinks(input, output, spectrumFilesState, modelRunState)

    output$modal <- reactive({
        if (loadState$state$uploadRequested) {
            "loadDigest"
        } else if (workingSet$editing) {
            "editWorkingSet"
        } else {
            NULL
        }
    })
    outputOptions(output, "modal", suspendWhenHidden = FALSE)
}
