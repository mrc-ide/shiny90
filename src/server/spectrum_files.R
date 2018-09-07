library(shiny)
library(purrr)
library(glue)
library(first90)

spectrumFiles <- function(input, output, state) {
    state$anyDataSets <- reactive({ length(state$dataSets) > 0 })
    state$combinedData <- reactive({
        if (state$anyDataSets()) {
            # TODO use all files, not just first one
            state$dataSets[[1]]$data
        }
    })

    observeEvent(input$spectrumFile, {
        inFile <- input$spectrumFile
        if (!is.null(inFile)) {
            dataSet = list(
                name = inFile$name,
                data = prepare_inputs(inFile$datapath)
            )
            state$dataSets <- c(state$dataSets, list(dataSet))
        }
    })

    output$anySpectrumDataSets <- reactive({ state$anyDataSets() })
    output$spectrumFilesCountry <- reactive({ "Malawi" })
    output$spectrum_combinedData <- renderDataTable(state$combinedData)

    renderSpectrumFileList(input, output, state)
    renderSpectrumPlots(output, state$combinedData)

    outputOptions(output, "anySpectrumDataSets", suspendWhenHidden = FALSE)

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
        map(state$dataSets, function(f) {
            removeEventId <- glue("remove_{f$name}")

            state$observerList <- addDynamicObserver(input, state$observerList, removeEventId, function() {
                index <- match(f$name, map(state$dataSets, function(x) { x$name }))
                state$dataSets <- state$dataSets[-index]
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

renderSpectrumPlots <- function(output, combinedData) {
    output$spectrum_plots <- renderPlot({
        if (!is.null(combinedData())) {
            plot_pnjz(combinedData())
        }
    })
}