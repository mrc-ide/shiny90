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
    output$spectrumFilesCountry <- reactive({ "Malawi" })
    output$spectrum_combinedData <- renderDataTable(state$combinedData)

    renderSpectrumFileList(input, output, state)
    renderSpectrumPlots(output)

    outputOptions(output, "anySpectrumFiles", suspendWhenHidden = FALSE)

    state
}

addDynamicObserver <- function(input, observerList, eventId, handler) {
    if (is.null(observerList[[eventId]])) {
        observerList[[eventId]] <- observeEvent(input[[eventId]], ignoreInit=TRUE, { handler() })
    }
    observerList
}

renderSpectrumFileList <- function(input, output, state) {
    state$observerList <- list()

    output$spectrumFileList <- renderUI({
        map(state$files, function(f) {
            removeEventId <- glue("remove_{f$name}")

            state$observerList <- addDynamicObserver(input, state$observerList, removeEventId, function() {
                index <- match(f$name, map(state$files, function(x) { x$name }))
                state$files <- state$files[-index]
            })

            tags$li("", class="list-group-item",
                span(f$name),
                HTML("&nbsp;&nbsp;"),
                actionButtonWithCustomClass(removeEventId, "Remove", cssClasses="btn-red",
                    span("", class="glyphicon glyphicon-remove", `aria-hidden`=TRUE)
                )
            )
        })
    })
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