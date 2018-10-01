library(eppasm)

spectrumFiles <- function(input, output, state) {

    state$country <- NULL
    state$anyDataSets <- shiny::reactive({ length(state$dataSets) > 0 })
    state$combinedData <-shiny::reactive({
        if (state$anyDataSets()) {
            # TODO use all files, not just first one
            state$dataSets[[1]]$data
        }
        else {
            NULL
        }
    })
    state$asDataFrame <- shiny::reactive({
        if (is.null(state$combinedData())) {
            NULL
        } else {
            summary <- first90::get_pjnz_summary_data(state$combinedData())
            f <- data.frame(
                "Year" = summary[["year"]],
                "Population" = summary[["pop"]],
                "Prevalence" = summary[["prevalence"]],
                "Incidence" = summary[["incidence"]],
                "People living with HIV" = summary[["plhiv"]]
            )
            f <- f[order(-Year)]
            f
        }
    })

    shiny::observeEvent(input$spectrumFile, {

        inFile <- input$spectrumFile
        state$spectrumFileError <- NULL

        if (!is.null(inFile)) {
             tryCatch({
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
                    state$spectrumFileError <- "You can only work with one country at a time. If you want to upload data for a different country you will have to remove the previously loaded file."
                    shinyjs::reset("spectrumFile")
                }
            },
            error=function(condition) {
                state$spectrumFileError <- glue::glue("Unable to read the contents of this file: {condition}")
                NULL
            })
        }
    })

    output$anySpectrumDataSets <- shiny::reactive({ state$anyDataSets() })
    output$spectrumFilesCountry <- shiny::reactive({ state$country })
    output$spectrum_combinedData <- shiny::renderDataTable({ state$asDataFrame() }, options = list (
        paging = FALSE,
        dom = "lrt"    # https://datatables.net/reference/option/dom
    ))
    output$spectrumFileError <- shiny::reactive({ state$spectrumFileError })

    renderSpectrumFileList(input, output, state)
    renderSpectrumPlots(output, state$combinedData)

    shiny::outputOptions(output, "anySpectrumDataSets", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "spectrumFileError", suspendWhenHidden = FALSE)

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
            first90::plot_pjnz(combinedData())
        }
    })
}