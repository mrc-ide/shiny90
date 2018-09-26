server <- function(input, output, session) {
    # State
    workingSet <- shiny::reactiveValues()
    workingSet$name <- NULL
    workingSet$notes <- NULL
    workingSet$creation_error <- NULL
    workingSet$editing <- FALSE

    surveyAndProgramData <- shiny::reactiveValues()
    surveyAndProgramData$survey <- NULL
    surveyAndProgramData$program_wide <- NULL

    spectrumFilesState <- shiny::reactiveValues()
    spectrumFilesState$dataSets <- list()
    spectrumFilesState$country <- NULL

    # Logic
    loadState <- handleLoad(input, workingSet, surveyAndProgramData, spectrumFilesState)
    workingSet <- workingSetLogic(input, output, session, loadState$workingSet)

    spectrumFilesState <- spectrumFiles(input, output, loadState$spectrumFilesState)
    surveyAndProgramData <- surveyAndProgramData(input, output, loadState$surveyAndProgramData, spectrumFilesState)
    plotInputs(output, surveyAndProgramData, spectrumFilesState)
    modelRunState <- modelRun(input, output, spectrumFilesState, surveyAndProgramData)

    output$digestDownload1 <- downloadDigest(workingSet, spectrumFilesState, surveyAndProgramData)
    enableNavLinks(input, output, spectrumFilesState, modelRunState, surveyAndProgramData)

    shiny::observeEvent(modelRunState$state, {
        if (modelRunState$state == "finished"){
            output$digestDownload2 <- downloadDigest(workingSet, spectrumFilesState, surveyAndProgramData)
        }
    })

    shiny::observeEvent(surveyAndProgramData$anyProgramData, {
        if (surveyAndProgramData$anyProgramData()){
            output$digestDownload3 <- downloadDigest(workingSet, spectrumFilesState, surveyAndProgramData)
        }
    })

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
