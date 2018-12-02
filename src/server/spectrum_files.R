
spectrumFiles <- function(input, output, state) {

    state$country <- NULL
    state$anyDataSets <- shiny::reactive({ length(state$dataSets) > 0 })
    state$combinedData <- shiny::reactive({
        if (state$anyDataSets()) {
            pjnz_in <- lapply(state$dataSets, function(x) {x$data})
            first90::prepare_inputs_from_extracts(pjnz_in)
        }
        else {
            NULL
        }
    })

    state$pjnz_summary <- shiny::reactive({
        if (is.null(state$combinedData())){
            NULL
        }
        else {
            first90::get_pjnz_summary_data(state$combinedData())
        }
    })

    state$anyDataPop <- shiny::reactive({ hasData("Population") })
    state$anyDataPlhiv <- shiny::reactive({ hasData("plhiv") })
    state$anyDataPrv <- shiny::reactive({ hasData("Prevalence") })
    state$anyDataInc <- shiny::reactive({ hasData("Incidence") })

    hasData <- function(column_name) {
        if (!is.null(state$asDataFrame())){
            df <- na.omit(state$asDataFrame()[[column_name]])
            length(df) > 0
        }
        else {
            FALSE
        }
    }

    state$asDataFrame <- shiny::reactive({
        if (is.null(state$pjnz_summary())) {
            NULL
        } else {
            summary <- state$pjnz_summary()
            df <- data.frame(Year = summary[["year"]],
                            Population = round(summary[["pop"]]/1000)*1000,
                            Prevalence = round(summary[["prevalence"]]*100, 2),
                            Incidence = round(summary[["incidence"]]*1000, 2),
                            plhiv = round(summary[["plhiv"]]/100)*100,
                            art_coverage = round((summary[["art_coverage"]]/summary[["plhiv"]])*100,1))
            df <- df[df$Year >= 2000,]
            df
        }
    })

    shiny::observeEvent(input$spectrumFile, {


        inFile <- input$spectrumFile
        state$spectrumFileError <- NULL

        if (!is.null(inFile)) {

            by(inFile, 1:nrow(inFile), function(row) {

              tryCatch({
                    pjn_file <- first90::file_in_zip(row$datapath, ".PJN$")
                    pjn <- read.csv(pjn_file, as.is = TRUE)
                    newCountry <- get_pjn_country(pjn)

                    if (!state$anyDataSets() || newCountry == state$country){

                        if (!state$anyDataSets()) {
                            state$country = newCountry
                        }

                        dataSet = list(name = row$name,
                                        data = first90::extract_pjnz(row$datapath))

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

            })

        }
    })

    output$anySpectrumDataSets <- shiny::reactive({ state$anyDataSets() })
    output$spectrumFilesCountry <- shiny::reactive({ state$country })
    output$spectrum_combinedData <- shiny::renderDataTable({ state$asDataFrame() }, options = c(
        defaultDataTableOptions(),
        list(
            columns = list(
                NULL, NULL, list(title="Prevalence (%)"), list(title="Incidence (per thousand)"),
                list(title = 'People living with HIV'),
                list(title = 'ART coverage (%)')
            )
        )
    ))
    output$spectrumFileError <- shiny::reactive({ state$spectrumFileError })

    renderSpectrumFileList(input, output, state)
    renderSpectrumPlots(output, state$pjnz_summary, state)

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

renderSpectrumPlots <- function(output, pjnz_summary, state) {

    output$spectrumTotalPop <- shiny::renderPlot({
        if (state$anyDataPop()) {
            first90::plot_pjnz_pop(pjnz_summary())
        }
    })

    output$spectrumPLHIV <- shiny::renderPlot({
        if (state$anyDataPlhiv()) {
            first90::plot_pjnz_plhiv(pjnz_summary())
        }
    })

    output$spectrumPrevalence <- shiny::renderPlot({
        if (state$anyDataPrv()) {
            first90::plot_pjnz_prv(pjnz_summary())
        }
    })

    output$spectrumIncidence <- shiny::renderPlot({
        if (state$anyDataInc()) {
            first90::plot_pjnz_inc(pjnz_summary())
        }
    })

}
