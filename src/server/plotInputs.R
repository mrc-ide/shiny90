library(shiny)

plotInputs <- function(input, output) {
    output$inputReview_a <- renderPlot({
        plot(faithful$waiting)
        title(main="Figure A")
    })
    output$inputReview_b <- renderPlot({
        plot(faithful$waiting)
        title(main="Figure B")
    })
}
