spectrumFiles <- function(input, output, state) {

    state$touched <- FALSE
    state$country <- NULL
    state$dataSets <- NULL

    state$anyDataSets <- shiny::reactive({ length(state$dataSets) > 0 })
    state$combinedData <- shiny::reactive({
        if (state$anyDataSets()) {
            pjnz_in <- lapply(state$dataSets, function(x) {x$data})
            fp <- first90::prepare_inputs_from_extracts(pjnz_in)

            fp
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

    state$regions <- shiny::reactive({
        if (state$anyDataSets()) {
            regions <- lapply(state$dataSets, function(x) if (is.null(x$region)) NA else x$region)
            regions[!is.na(regions)]
        }
        else {
            c()
        }
    })

    state$aggregatingToNational <- shiny::reactive({
        !is.null(state$regions()) && length(state$regions()) > 1
    })

    state$treatAsRegional <- shiny::reactive({
        !is.null(state$regions()) && length(state$regions()) == 1
    })

    state$countryAndRegionName <- shiny::reactive({
        if (state$treatAsRegional()){
            paste(state$country, state$regions()[[1]], sep=" - ")
        }
        else {
            state$country
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
                    newCountry <- first90::get_pjn_country(pjn)
                    newRegion <- first90::get_pjn_region(pjn)

                    if (!state$anyDataSets() || newCountry == state$country){
                        data <- first90::extract_pjnz(row$datapath)
                        addDataSet(state, data, row$name, newCountry, newRegion)
                    }
                    else {
                        state$spectrumFileError <- "You can only work with one country at a time.
                        If you want to upload data for a different country you will have to remove the previously loaded files."
                        shinyjs::reset("spectrumFile")
                    }
                },
                error=function(condition) {
                    shinyjs::reset("spectrumFile")
                    state$spectrumFileError <- glue::glue("Unable to read the contents of this file: {condition}")
                    NULL
                })

            })

        }

    })

    shiny::observeEvent(input$spectrumFilePair, {

        inFiles <- input$spectrumFilePair
        state$spectrumFilePairError <- NULL

        if (!is.null(inFiles)) {

            if (nrow(inFiles) != 2){
                state$spectrumFilePairError <- "Please select a pair of files - one .PJN and one .DP"
            }
            else {
                tryCatch({
                    newCountry <- NULL
                    dp_file <- NULL
                    pjn_file <- NULL

                    by(inFiles, 1:nrow(inFiles), function(row) {

                        if (grepl(".dp", tolower(row$datapath))){
                            dp_file <<- row$datapath
                        }
                        if (grepl(".pjn", tolower(row$datapath))){
                            pjn_file <<- row$datapath
                        }
                    })

                    if (is.null(pjn_file) || is.null(dp_file)){
                        shinyjs::reset("spectrumFilePair")
                        state$spectrumFilePairError <- "You must provide one .PJN and one .DP file. Please check your selected files."
                        data <- NULL
                    }
                    else {
                        pjn <- read.csv(pjn_file, as.is = TRUE)
                        newCountry <- first90::get_pjn_country(pjn)
                        newRegion <- first90::get_pjn_region(pjn)

                        if (!state$anyDataSets() || newCountry == state$country){
                            data <- first90::extract_pjnz(dp_file = dp_file, pjn_file = pjn_file)
                            addDataSet(state, data, paste(inFiles[[1]][[1]],inFiles[[1]][[2]], sep="+"), newCountry, newRegion)
                        }
                        else {
                            state$spectrumFilePairError <- "You can only work with one country at a time.
                        If you want to upload data for a different country you will have to remove the previously loaded files."
                            shinyjs::reset("spectrumFilePair")
                        }
                    }
                },
                error=function(condition) {
                    str(condition)
                    shinyjs::reset("spectrumFilePair")
                    state$spectrumFilePairError <- glue::glue("Unable to read the contents of these files: {condition}")
                })
            }
        }
    })

    output$usePJNZ <- shiny::reactive({
        input$spectrumFileType == ".PJNZ"
    })

    output$anySpectrumDataSets <- shiny::reactive({ state$anyDataSets() })
    output$spectrum_combinedData <- shiny::renderDataTable({ state$asDataFrame() }, options = c(
        defaultDataTableOptions(),
        list(
            columns = list(
                NULL, list(title="Population<br/>15+"), 
                list(title="Prevalence (%)<br/>15-49"), 
                list(title="Incidence (per thousand)<br/>15-49"),
                list(title = 'People living with HIV<br/>15+'),
                list(title = 'ART coverage (%)<br/>15+')
            )
        )
    ))
    output$spectrumFileError <- shiny::reactive({ state$spectrumFileError })
    output$spectrumFilePairError <- shiny::reactive({ state$spectrumFilePairError })

    output$aggregatingToNational <- shiny::reactive({
        state$aggregatingToNational()
    })

    output$countryAndRegionName <- shiny::reactive({
        state$countryAndRegionName()
    })

    renderSpectrumFileList(input, output, state)
    renderSpectrumPlots(output, state$pjnz_summary, state)

    shiny::outputOptions(output, "anySpectrumDataSets", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "spectrumFileError", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "spectrumFilePairError", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "usePJNZ", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "aggregatingToNational", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "countryAndRegionName", suspendWhenHidden = FALSE)

    state
}

addDynamicObserver <- function(input, observerList, eventId, handler) {
    if (is.null(observerList[[eventId]])) {
        observerList[[eventId]] <- shiny::observeEvent(input[[eventId]], ignoreInit = TRUE, { handler() })
    }
    observerList
}

addDataSet <- function(state, data, name, newCountry, newRegion){

    if (is.null(data))
        return()

    if (!state$anyDataSets()) {
        state$country = newCountry
    }

    dataSet = list(name = name, data = data, region = newRegion)
    state$dataSets <- c(state$dataSets, list(dataSet))
    state$touched <- TRUE

}

renderSpectrumFileList <- function(input, output, state) {
    state$observerList <- list()

    output$spectrumFileList <- shiny::renderUI({
        purrr::map(state$dataSets, function(f) {
            removeEventId <- glue::glue("remove_{f$name}")

            state$observerList <- addDynamicObserver(input, state$observerList, removeEventId, function() {
                index <- match(f$name, purrr::map(state$dataSets, function(x) { x$name }))
                state$dataSets <- state$dataSets[-index]
                if (length(state$dataSets) == 0){
                    state$country <- NULL
                }
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
