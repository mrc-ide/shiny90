library(shiny)

server <- function(input, output) {
    output$inputReview <- renderPlot({
        plot(faithful$waiting)
    })
}
