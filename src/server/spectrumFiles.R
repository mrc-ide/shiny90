library(shiny)
library(purrr)
library(glue)

spectrumFiles <- function(input, output) {
    state <- reactiveValues()
    state$pjnzFilePath <- ""
    state$spectrumFiles <- character()
    state$anySpectrumFiles <- reactive({ length(state$spectrumFiles) > 0 })

    observeEvent(input$spectrumFile, {
        inFile <- input$spectrumFile
        if (!is.null(inFile)) {
            state$pjnzFilePath <- inFile$datapath
            filename <- inFile$name
            output[[glue("spectrumReview_{filename}")]] <- renderPlot({
                plot(faithful$waiting)
                title(main="Prevalence trend")
            })
            state$spectrumFiles <- c(state$spectrumFiles, filename)
        }
    })
    output$anySpectrumFiles <- reactive({state$anySpectrumFiles})
    output$spectrumFileTabs <- renderUI({
        tabs = map(state$spectrumFiles, function(filename) {
            tabPanel(filename, plotOutput(glue("spectrumReview_{filename}")))
        })
        do.call(tabsetPanel, tabs)
    })
    outputOptions(output, "anySpectrumFiles", suspendWhenHidden = FALSE)

    state
}
