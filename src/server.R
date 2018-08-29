library(shiny)

server <- function(input, output) {
    output$inputReview_totalNumberOfTests <- renderPlot({
        Sys.sleep(2)
        plot(faithful$waiting)
        title(main="Total number of tests")
    })
    output$inputReview_numberOfPositiveTests <- renderPlot({
        plot(faithful$waiting)
        title(main="Number of positive tests (in 1000)")
    })
    output$inputReview_percentageNegativeOfTested <- renderPlot({
        plot(faithful$waiting)
        title(main="% negative of all ever tested")
    })
    output$inputReview_percentagePLHIVOfTested <- renderPlot({
        plot(faithful$waiting)
        title(main="% PLHIV of all ever tested")
    })
    output$inputReview_percentageTested <- renderPlot({
        plot(faithful$waiting)
        title(main="% of population ever tested")
    })
    output$inputReview_firstAndSecond90 <- renderPlot({
        plot(faithful$waiting)
        title(main="First and second 90s")
    })
}
