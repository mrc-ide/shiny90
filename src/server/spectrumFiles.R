library(shiny)
library(purrr)
library(glue)

spectrumFiles <- function(input, output) {
    state <- reactiveValues()
    state$files <- list()
    state$anyFiles <- reactive({ length(state$files) > 0 })

    observeEvent(input$spectrumFile, {
        inFile <- input$spectrumFile
        if (!is.null(inFile)) {
            state$files <- c(state$files, list(inFile))
        }
    })
    output$anySpectrumFiles <- reactive({ state$anyFiles() })
    output$spectrumFileList <- renderUI({
        map(state$files, function(f) {
            tags$li(f$name)
        })
    })
    output$spectrumFilesCountry <- reactive({ "Malawi" })
    renderSpectrumPlots(output)

    outputOptions(output, "anySpectrumFiles", suspendWhenHidden = FALSE)

    state
}

renderSpectrumPlots <- function(output) {
    output$spectrum_hivPrevalance <- renderPlot({
        plot(faithful$waiting)
        title(main="HIV prevalence")
    })
    output$spectrum_hivIncidence <- renderPlot({
        plot(faithful$waiting)
        title(main="HIV incidence")
    })
    output$spectrum_populationSize <- renderPlot({
        plot(faithful$waiting)
        title(main="Population size")
    })
    output$spectrum_numberOfPeopleLivingWithHIV <- renderPlot({
        plot(faithful$waiting)
        title(main="Number of people living with HIV")
    })
}