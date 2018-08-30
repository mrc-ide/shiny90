library(shiny)

server <- function(input, output) {
    # ---- Upload spectrum files ----
    #spectrumFiles <- reactiveVal(complex())
    output$spectrumFile <- reactive({FALSE})
    output$spectrumFile <- reactive({
        inFile <- input$spectrumFile

        output$spectrumReview <- renderPlot({
            plot(faithful$waiting)
            title(main="Prevalence trend")
        })

        !is.null(inFile)
        #spectrumFiles(c(spectrumFiles(), inFile$name))
        #spectrumFiles()
    })
    outputOptions(output, "spectrumFile", suspendWhenHidden = FALSE)

    # ---- renderInputReviewFigures
    output$inputReview_a <- renderPlot({
        plot(faithful$waiting)
        title(main="Figure A")
    })
    output$inputReview_b <- renderPlot({
        plot(faithful$waiting)
        title(main="Figure B")
    })

    # ---- renderModelRunResults ----
    output$requestedModelRun <- reactive({FALSE})
    observeEvent(input$runModel, {
        output$requestedModelRun <- reactive({TRUE})
        output$modelFittingResults <- renderPlot({
            plot(faithful$waiting)
        })
        output$outputs_totalNumberOfTests <- renderPlot({
            plot(faithful$waiting)
            title(main="Total number of tests")
        })
        output$outputs_numberOfPositiveTests <- renderPlot({
            plot(faithful$waiting)
            title(main="Number of positive tests (in 1000)")
        })
        output$outputs_percentageNegativeOfTested <- renderPlot({
            plot(faithful$waiting)
            title(main="% negative of all ever tested")
        })
        output$outputs_percentagePLHIVOfTested <- renderPlot({
            plot(faithful$waiting)
            title(main="% PLHIV of all ever tested")
        })
        output$outputs_percentageTested <- renderPlot({
            plot(faithful$waiting)
            title(main="% of population ever tested")
        })
        output$outputs_firstAndSecond90 <- renderPlot({
            plot(faithful$waiting)
            title(main="First and second 90s")
        })
    })
    outputOptions(output, "requestedModelRun", suspendWhenHidden = FALSE)
}
