library(shiny)

plotInputs <- function(output, surveyAndProgramData) {
    output$inputReview <- renderPlot({
        plot_inputdata(surveyAndProgramData$program())
    })
}
