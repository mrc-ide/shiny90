library(shiny)

server <- function(input, output) {
    # State
    workingSet <- reactiveValues()
    workingSet$name <- NULL
    workingSet$notes <- NULL
    workingSet$creation_error <- NULL

    surveyAndProgramData <- reactiveValues()
    surveyAndProgramData$survey <- NULL
    surveyAndProgramData$program <- NULL

    spectrumFilesState <- reactiveValues()
    spectrumFilesState$dataSets <- list()

    # Logic
    loadState <- handleLoad(input, workingSet, surveyAndProgramData, spectrumFilesState)
    workingSet <- workingSetLogic(input, output, loadState$workingSet)

    spectrumFilesState <- spectrumFiles(input, output, loadState$spectrumFilesState)
    surveyAndProgramData <- surveyAndProgramData(input, output, loadState$surveyAndProgramData)
    plotInputs(output, surveyAndProgramData$program)
    modelRunState <- modelRun(input, output, spectrumFilesState, surveyAndProgramData)

    handleSave(input, output, workingSet, spectrumFilesState, surveyAndProgramData)
    enableNavLinks(input, output, spectrumFilesState, modelRunState)

    output$modal <- reactive({
        if (loadState$state$uploadRequested) {
            "loadDigest"
        } else {
            NULL
        }
    })
    outputOptions(output, "modal", suspendWhenHidden = FALSE)
}
