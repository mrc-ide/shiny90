library(shiny)

plotInputs <- function(output, programData) {
    output$inputReview <- renderPlot({
        plot_inputdata(programData)
    })
}
