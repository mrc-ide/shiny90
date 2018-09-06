library(shiny)
library(purrr)
library(glue)
library(first90)

spectrumFiles <- function(input, output) {
    state <- reactiveValues()
    state$files <- list()
    state$anyFiles <- reactive({ length(state$files) > 0 })
    state$combinedData <- reactive({
        if (state$anyFiles()) {
            # TODO use all files, not just first one
            prepare_inputs(state$files[[1]]$datapath)
        }
    })

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
    renderSpectrumPlots(output, state$combinedData)

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

renderSpectrumPlots <- function(output, combinedData) {
    output$spectrum_plots <- renderPlot({
        if (!is.null(combinedData())) {
            plot_pnjz(combinedData())
        }
    })
}