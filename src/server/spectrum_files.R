library(eppasm)

spectrumFiles <- function(input, output, state) {

    state$country <- NULL
    state$anyDataSets <- shiny::reactive({ length(state$dataSets) > 0 })
    state$combinedData <-shiny::reactive({
        if (state$anyDataSets()) {

            str("spectrum data changed")
            # TODO use all files, not just first one
            state$dataSets[[1]]$data
        }
        else {

            str("spectrum data changed")
            NULL
        }
    })

    shiny::observeEvent(input$spectrumFile, {

        inFile <- input$spectrumFile
        state$multipleCountryError <- FALSE

        if (!is.null(inFile)) {

            newCountry <- eppasm::read_country(inFile$datapath)

            if (!state$anyDataSets() || newCountry == state$country){

                if (!state$anyDataSets()) {
                    state$country = newCountry
                }

                dataSet = list(name = inFile$name,
                data = first90::prepare_inputs(inFile$datapath))

                state$dataSets <- c(state$dataSets, list(dataSet))
            }
            else {
                state$multipleCountryError <- TRUE
                shinyjs::reset("spectrumFile")
            }
        }
    })

    output$anySpectrumDataSets <- shiny::reactive({ state$anyDataSets() })
    output$spectrumFilesCountry <- shiny::reactive({ state$country })
    output$spectrum_combinedData <- shiny::renderDataTable(state$combinedData)
    output$multipleCountryError <- shiny::reactive({ state$multipleCountryError })

    renderSpectrumFileList(input, output, state)
    renderSpectrumPlots(output, state$combinedData)

    shiny::outputOptions(output, "anySpectrumDataSets", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "multipleCountryError", suspendWhenHidden = FALSE)

    state
}

addDynamicObserver <- function(input, observerList, eventId, handler) {
    if (is.null(observerList[[eventId]])) {
        observerList[[eventId]] <- shiny::observeEvent(input[[eventId]], ignoreInit = TRUE, { handler() })
    }
    observerList
}

    renderSpectrumFileList <- function(input, output, state) {
    state$observerList <- list()

    output$spectrumFileList <- shiny::renderUI({
        purrr::map(state$dataSets, function(f) {
            removeEventId <- glue::glue("remove_{f$name}")

            state$observerList <- addDynamicObserver(input, state$observerList, removeEventId, function() {
                index <- match(f$name, purrr::map(state$dataSets, function(x) { x$name }))
                state$dataSets <- state$dataSets[-index]
            })

            shiny::tags$li("", class = "list-group-item",
                shiny::span(f$name),
                shiny::HTML("&nbsp;&nbsp;"),
                actionButtonWithCustomClass(removeEventId, "Remove", cssClasses = "btn-red",
                    shiny::span("", class = "glyphicon glyphicon-remove", `aria-hidden`=TRUE)
                )
            )
        })
    })
}

renderSpectrumPlots <- function(output, combinedData) {
    output$spectrum_plots <- shiny::renderPlot({
        if (!is.null(combinedData())) {
            first90::plot_pnjz(combinedData())
        }
    })
}