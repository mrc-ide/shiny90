server <- function(input, output) {
    workingSet <- workingSetLogic(input, output)

    spectrumFilesState <- spectrumFiles(input, output)
    surveyAndProgramData <- surveyAndProgramData(input, output)
    plotInputs(output, surveyAndProgramData$program)
    modelRunState <- modelRun(input, output, spectrumFilesState, surveyAndProgramData)

    handleSaveAndLoad(input, output, workingSet, spectrumFilesState, surveyAndProgramData)
    enableNavLinks(input, output, spectrumFilesState, modelRunState)
}
