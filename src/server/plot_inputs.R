library(shiny)

plotInputs <- function(output, surveyAndProgramData, spectrumFilesState) {
    output$inputReview <- renderPlot({
        plot_inputdata(surveyAndProgramData$program(), spectrumFilesState$combinedData())
    })
}
