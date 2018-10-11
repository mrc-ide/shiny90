server <- function(input, output, session) {
    # State
    workingSet <- shiny::reactiveValues()
    workingSet$name <- NULL
    workingSet$notes <- NULL
    workingSet$creation_error <- NULL
    workingSet$editing <- FALSE

    surveyAndProgramData <- shiny::reactiveValues()
    surveyAndProgramData$survey <- NULL
    surveyAndProgramData$program_data <- NULL

    spectrumFilesState <- shiny::reactiveValues()
    spectrumFilesState$dataSets <- list()
    spectrumFilesState$country <- NULL

    modelRunState <- shiny::reactiveValues()
    modelRunState$state <- "not_run"
    modelRunState$outputs <- list()

    # Logic
    loadState <- handleLoad(input, workingSet, surveyAndProgramData, spectrumFilesState, modelRunState)
    workingSet <- workingSetLogic(input, output, session, loadState$workingSet)

    spectrumFilesState <- spectrumFiles(input, output, loadState$spectrumFilesState)
    surveyAndProgramData <- surveyAndProgramData(input, output, loadState$surveyAndProgramData, spectrumFilesState)
    plotInputs(output, surveyAndProgramData, spectrumFilesState)
    modelRunState <- modelRun(input, output, loadState$modelRunState, spectrumFilesState, surveyAndProgramData)

    handleSave(output, workingSet, spectrumFilesState, surveyAndProgramData, modelRunState)
    enableNavLinks(input, output, spectrumFilesState, modelRunState, surveyAndProgramData)


    output$modal <- shiny::reactive({
        if (loadState$state$uploadRequested) {
            "loadDigest"
        } else if (workingSet$editing) {
            "editWorkingSet"
        } else {
            NULL
        }
    })
    shiny::outputOptions(output, "modal", suspendWhenHidden = FALSE)
}
