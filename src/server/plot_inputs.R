plotInputs <- function(output, surveyAndProgramData, spectrumFilesState) {
    output$inputReview <- shiny::renderPlot({
        first90::plot_inputdata(surveyAndProgramData$program(), spectrumFilesState$combinedData())
    })
}
