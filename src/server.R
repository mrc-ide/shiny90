server <- function(input, output) {
    workingSet(input, output)
    spectrumFilesState <- spectrumFiles(input, output)
    surveyAndProgramData <- surveyAndProgramData(input, output)
    plotInputs(input, output)
    modelRun(input, output, spectrumFilesState, surveyAndProgramData)

    enableNavLinks(input, output, spectrumFilesState)
}
