library(shiny)
library(purrr)
library(glue)

handleUploadAndReviewOfSpectrumFiles <- function(input, output) {
    pjnzFilePath <- reactiveVal("")
    spectrumFiles <- reactiveVal(character())
    observeEvent(input$spectrumFile, {
        inFile <- input$spectrumFile
        if (!is.null(inFile)) {
            pjnzFilePath(inFile$datapath)
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

    pjnzFilePath
}
