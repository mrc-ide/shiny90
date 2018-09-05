library(shiny)
library(purrr)
library(glue)

spectrumFiles <- function(input, output) {
    state <- reactiveValues()
    state$files <- list()
    state$anyFiles <- reactive({ length(state$files) > 0 })
    state$combinedData <- {
        years <- c(2007, 2008)
        population <- c(1000, 1200)
        peopleLivingWithHIV <- c(25, 30)
        prevalence <- c(0.025, 0.026)
        incidence <- c(4, 5)
        artCoverage <- c(0.5, 0.55)
        data.frame(years, population, peopleLivingWithHIV, prevalence, incidence, artCoverage)
    }

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
    output$spectrum_combinedData <- renderDataTable(state$combinedData)

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