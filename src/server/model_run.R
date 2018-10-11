modelRun <- function(input, output, state, spectrumFilesState, surveyAndProgramData) {
    # the model fitting code expects survey data as a data table and program data as a data frame
    # it could presumably be re-written to deal with survey data as a data frame but for now we're just
    # converting survey data to the expected format
    state$surveyAsDataTable <- shiny::reactive({
        if (is.null(surveyAndProgramData$survey)) {
            NULL
        } else {
            data.table::as.data.table(surveyAndProgramData$survey, keep.rownames = TRUE)
        }
    })

    state$preparedSurveyData <- shiny::reactive({
        if (is.null(state$surveyAsDataTable)) {
            NULL
        } else {
            ageGroup <- c('15-24','25-34','35-49')
            first90::select_hts(state$surveyAsDataTable(), spectrumFilesState$country, ageGroup)
        }
    })

    state$likelihood <- shiny::reactive({
        tryCatch({
            first90::prepare_hts_likdat(
                state$preparedSurveyData(),
                surveyAndProgramData$program_data,
                spectrumFilesState$combinedData()
            )
        }, error = function(e) {
            print(glue::glue("An error occured calculating likelihood: {e}"))
            NULL
        })
    })

    shiny::observeEvent(input$runModel, {
        state$optim <- tryCatch({
            fitModel(state$likelihood(), spectrumFilesState$combinedData())
        }, error = function(e) {
            str(e)
            state$state <- "error"
        })
    })

    shiny::observeEvent(state$optim, {
        if (!is.null(state$optim)) {
            # model fit results
            fp <- first90::create_hts_param(state$optim$par, spectrumFilesState$combinedData())
            mod <- eppasm::simmod.specfp(fp)

            # model output
            out_evertest = first90::get_out_evertest(mod, fp)

            plotModelRunResults(output, state$surveyAsDataTable(), state$likelihood(),
                                fp, mod, spectrumFilesState$country, out_evertest)
            state$state <- "finished"
        }
    })

    output$modelRunState <- shiny::reactive({ state$state })
    shiny::outputOptions(output, "modelRunState", suspendWhenHidden = FALSE)

    # A change event will occur the first time the user navigates to the input data page
    # but this first change event doesn't represent a change to the data.
    # So we only reset the state on subsequent change events.
    shiny::observeEvent(surveyAndProgramData$survey, {
        if (surveyAndProgramData$surveyTableChanged > 1){
            state$state <- "stale"
        }
    })

    shiny::observeEvent(surveyAndProgramData$program_data, {
        if (surveyAndProgramData$programTableChanged > 1){
            state$state <- "stale"
        }
    })

    shiny::observeEvent(spectrumFilesState$combinedData(), {
        state$state <- "stale"
    })

    shiny::observeEvent(state$optim_from_digest, {
        if (!is.null(state$optim_from_digest)) {
            state$optim <- state$optim_from_digest
            state$optim_from_digest <- NULL
        }
    })
    
    state
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