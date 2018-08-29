library(shiny)

server <- function(input, output) {
    output$inputReview <- renderPlot({
        plot(faithful$waiting)
    }, width = 500, height = 500)
    outputOptions(output, "inputReview", suspendWhenHidden=FALSE)
}
