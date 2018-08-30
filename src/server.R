library(shiny)
library(purrr)
library(glue)

server <- function(input, output) {
    # ---- Working set ----
    workingSet <- reactiveVal(
        list(name=NULL, notes=NULL)
    )
    output$workingSetSelected <- reactive({ !is.null(workingSet()$name) })
    output$workingSet_name <- reactive({ workingSet()$name })
    output$workingSet_notes <- reactive({ workingSet()$notes })
    observeEvent(input$startNewWorkingSet, { workingSet(list(name=input$workingSetName, notes="")) })
    outputOptions(output, "workingSetSelected", suspendWhenHidden = FALSE)

    # ---- Upload spectrum files ----
    spectrumFiles <- reactiveVal(character())
    observeEvent(input$spectrumFile, {
        inFile <- input$spectrumFile
        if (!is.null(inFile)) {
            filename <- inFile$name
            output[[glue("spectrumReview_{filename}")]] <- renderPlot({
                plot(faithful$waiting)
                title(main="Prevalence trend")
            })
            spectrumFiles(c(spectrumFiles(), filename))
        }
    })
    output$anySpectrumFiles <- reactive({length(spectrumFiles()) > 0})
    output$spectrumFileTabs <- renderUI({
        tabs = map(spectrumFiles(), function(filename) {
            tabPanel(filename, plotOutput(glue("spectrumReview_{filename}")))
        })
        do.call(tabsetPanel, tabs)
    })
    outputOptions(output, "anySpectrumFiles", suspendWhenHidden = FALSE)

    # ---- Render input review figures
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
