modelRun <- function(input, output, spectrumFilesState, surveyAndProgramData) {
    state <- shiny::reactiveValues()
    state$state <- "not_run"
    state$mod <- NULL
    state$fp <- NULL
    state$simul <- NULL

    shiny::observeEvent(input$runModel, {

        # the model fitting code expects survey data as a data table and program data as a data frame
        # it could presumably be re-written to deal with survey data as a data frame but for now we're just
        # converting survey data to the expected format
        surveyAsDataTable <- data.table::as.data.table(surveyAndProgramData$survey, keep.rownames = TRUE)

        out <- tryCatch({

                fitModel(surveyAsDataTable,
                        surveyAndProgramData$program_data,
                        spectrumFilesState$combinedData(),
                        spectrumFilesState$country)

            },
            error = function(e) {
                str(e)
                state$state <- "error"
            })

        if (length(out) > 1){

            # model fit results
            likdat <- out$likdat
            state$fp <- out$fp
            state$mod <- out$mod
            state$simul <- out$simul

            # model output
            out_evertest = first90::get_out_evertest(state$mod, state$fp)

            plotModelRunResults(output, surveyAsDataTable, likdat, state$fp,
                                state$mod, spectrumFilesState$country, out_evertest)
            state$state <- "finished"
        }
    })

    output$modelRunState <- shiny::reactive({ state$state })
    shiny::outputOptions(output, "modelRunState", suspendWhenHidden = FALSE)

    output$outputs_table_ever_tested <- renderModelResultsTable(state, function(state) {
        first90::tab_out_evertest(state$mod, state$fp, simul = state$simul)
    })
    output$outputs_table_aware <- renderModelResultsTable(state, function(state) {
        first90::tab_out_aware(state$mod, state$fp, simul = state$simul)
    })
    output$outputs_table_art_coverage <- renderModelResultsTable(state, function(state) {
        first90::tab_out_artcov(state$mod, state$fp)
    })

    # A change event will occur the first time the user navigates to the input data page
    # but this first change event doesn't represent a change to the data.
    # So we only reset the state on subsequent change events.
    shiny::observeEvent(surveyAndProgramData$survey, {
        if (surveyAndProgramData$surveyTableChanged > 1){
            state$state <- ""
        }
    })

    shiny::observeEvent(surveyAndProgramData$program_data, {
        if (surveyAndProgramData$programTableChanged > 1){
            state$state <- ""
        }
    })

    shiny::observeEvent(spectrumFilesState$combinedData(), {
        state$state <- ""
    })
    
    state
}

renderModelResultsTable <- function(state, func) {
    shiny::renderDataTable({
        if (is.null(state$mod) || is.null(state$fp)) {
            NULL
        } else {
            func(state)
        }
    }, options = defaultDataTableOptions())
}

plotModelRunResults <- function(output, surveyAsDataTable, likdat, fp, mod, country, out_evertest) {
    output$outputs_totalNumberOfTests <- shiny::renderPlot({
        first90::plot_out_nbtest(mod, fp, likdat, country)
    })

    output$outputs_numberOfPositiveTests <- shiny::renderPlot({
        first90::plot_out_nbpostest(mod, fp, likdat, country)
    })

    output$outputs_percentageNegativeOfTested <- shiny::renderPlot({
        first90::plot_out_evertestneg(mod, fp, likdat, country, surveyAsDataTable, out_evertest)
    })

    output$outputs_percentagePLHIVOfTested <- shiny::renderPlot({
        first90::plot_out_evertestpos(mod, fp, likdat, country, surveyAsDataTable, out_evertest)
    })

    output$outputs_percentageTested <- shiny::renderPlot({
        first90::plot_out_evertest(mod, fp, likdat, country, surveyAsDataTable, out_evertest)
    })

    output$outputs_firstAndSecond90 <- shiny::renderPlot({
        first90::plot_out_90s(mod, fp, likdat, country, out_evertest)
    })

    output$outputs_womenEverTested <- shiny::renderPlot({
        first90::plot_out_evertest_fbyage(mod, fp, likdat, country, surveyAsDataTable, out_evertest)
    })

    output$outputs_menEverTested <- shiny::renderPlot({
        first90::plot_out_evertest_mbyage(mod, fp, likdat, country, surveyAsDataTable, out_evertest)
    })
}