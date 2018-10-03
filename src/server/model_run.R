modelRun <- function(input, output, spectrumFilesState, surveyAndProgramData) {
    state <- shiny::reactiveValues()
    state$state <- "not_run"

    shiny::observeEvent(input$runModel, {

        # the model fitting code expects survey data as a data table and program data as a data frame
        # it could presumably be re-written to deal with survey data as a data frame but for now we're just
        # converting survey data to the expected format
        surveyAsDataTable <- data.table::as.data.table(surveyAndProgramData$survey, keep.rownames = TRUE)

        out <- tryCatch({
                fitModel(surveyAsDataTable, surveyAndProgramData$program(), spectrumFilesState$combinedData())
            },
            error = function(e) {
                str(e)
                state$state <- "error"
            })

        if (length(out) > 1){

            # model fit results
            likdat <- out$likdat
            fp <- out$fp
            mod <- out$mod

            plotModelRunResults(output, spectrumFilesState$country, surveyAsDataTable, likdat, fp, mod)
            state$state <- "finished"

        }

        str(out)
    })

    output$modelRunState <- shiny::reactive({ state$state })
    shiny::outputOptions(output, "modelRunState", suspendWhenHidden = FALSE)

    # A change event will occur the first time the user navigates to the input data page
    # but this first change event doesn't represent a change to the data.
    # So we only reset the state on subsequent change events.
    shiny::observeEvent(surveyAndProgramData$survey, {
        if (surveyAndProgramData$surveyTableChanged > 1){
            state$state <- ""
        }
    })

    shiny::observeEvent(surveyAndProgramData$program_wide, {
        if (surveyAndProgramData$programTableChanged > 1){
            state$state <- ""
        }
    })

    shiny::observeEvent(spectrumFilesState$combinedData(), {
        state$state <- ""
    })
    
    state
}

plotModelRunResults <- function(output, country, surveyAsDataTable, likdat, fp, mod) {

    out_evertest <- first90::get_out_evertest(fp, mod)

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
        first90::plot_out_90s(mod, fp, likdat, country)
    })

    output$outputs_womenEverTested <- shiny::renderPlot({
        first90::plot_out_evertest_fbyage(mod, fp, likdat, country, surveyAsDataTable, out_evertest)
    })

    output$outputs_menEverTested <- shiny::renderPlot({
        first90::plot_out_evertest_mbyage(mod, fp, likdat, country, surveyAsDataTable, out_evertest)
    })
}