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
            error = function() {
                state$state <- "error"
            })

        if (length(out) > 0){
            # model fit results
            likdat <- out$likdat
            fp <- out$fp
            mod <- eppasm::simmod.specfp(fp)

            # model output
            out_evertest = outEverTest(fp, mod)

            plotModelRunResults(output, surveyAsDataTable, likdat, fp, mod, out_evertest)
            state$state <- "finished"
        }

    })

    output$modelRunState <- shiny::reactive({ state$state })
    shiny::outputOptions(output, "modelRunState", suspendWhenHidden = FALSE)

    state
}

plotModelRunResults <- function(output, surveyAsDataTable, likdat, fp, mod, out_evertest) {
    output$outputs_totalNumberOfTests <- shiny::renderPlot({
        plotTotalNumberOfTests(fp, mod, likdat)
    })

    output$outputs_numberOfPositiveTests <- shiny::renderPlot({
        plotNumberOfPositiveTests(fp, mod, likdat)
    })

    output$outputs_percentageNegativeOfTested <- shiny::renderPlot({
        plotPercentageNegativeOfTested(surveyAsDataTable, out_evertest)
    })

    output$outputs_percentagePLHIVOfTested <- shiny::renderPlot({
        plotPercentagePLHIVOfTested(surveyAsDataTable, out_evertest)
    })

    output$outputs_percentageTested <- shiny::renderPlot({
        plotPercentageTested(surveyAsDataTable, out_evertest)
    })

    output$outputs_firstAndSecond90 <- shiny::renderPlot({
        plotFirstAndSecond90(fp, mod, out_evertest)
    })
}