library(shiny)

server <- function(input, output) {
    renderModelFittingResults(input, output)
    renderModelRunResults(input, output)
    renderInputReviewFigures(input, output)
}

renderModelFittingResults <- function(input, output) {
    output$requestedModelFitting <- reactive({FALSE})
    observeEvent(input$startModelFitting, {
        output$requestedModelFitting <- reactive({TRUE})
        output$modelFittingResults <- renderPlot({
            plot(faithful$waiting)
        })
    })
    outputOptions(output, "requestedModelFitting", suspendWhenHidden = FALSE)
}

renderModelRunResults <- function(input, output) {
    output$requestedModelRun <- reactive({FALSE})
    observeEvent(input$runModel, {
        output$requestedModelRun <- reactive({TRUE})
        output$modelRunResults <- renderPlot({
            plot(faithful$waiting)
        })
    })
    outputOptions(output, "requestedModelRun", suspendWhenHidden = FALSE)
}

renderInputReviewFigures <- function(input, output) {
    output$inputReview_totalNumberOfTests <- renderPlot({
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
