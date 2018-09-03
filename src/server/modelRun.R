library(shiny)
library(first90)

modelRun <- function(input, output, spectrumFilesState, surveyAndProgramData) {
    state <- reactiveValues()
    state$state <- "not_run"
    state$running <- FALSE
    state$surveyAsDataTable <- NULL
    state$likdat <- NULL
    state$fp <- NULL
    state$mod <- NULL
    state$out_evertest <- NULL

    observeEvent(input$runModel, {
        state$state <- "begin"
        state$running = TRUE
    })
    output$modelRunning <- reactive({ state$running })
    output$modelRunState <- reactive({ state$state })
    observe({
        if (state$state == "begin") {
            state$state <- "fitting"
            # the model fitting code expects survey data as a data table and program data as a data frame
            # it could presumably be re-written to deal with survey data as a data frame but for now we're just
            # converting survey data to the expected format
            state$surveyAsDataTable <- as.data.table(surveyAndProgramData$survey, keep.rownames=TRUE)

            out <- fitModel(state$surveyAsDataTable, surveyAndProgramData$program, spectrumFilesState$pjnzFilePath)
            # model fit results
            state$likdat <- out$likdat
            state$fp <- out$fp
            state$mod <- eppasm::simmod.specfp(state$fp)
            state$state <- "fitted"
        }
    })
    observe({
        if (state$state == "fitted") {
            state$state <- "running"

            # model output
            state$out_evertest = outEverTest(state$fp, state$mod)
            state$state <- "run"
        }
    })
    observe({
        if (state$state == "run") {
            plotModelRunResults(output, state)
            state$state <- "finished"
            state$running <- FALSE
        }
    })
    outputOptions(output, "modelRunState", suspendWhenHidden = FALSE)
    outputOptions(output, "modelRunning", suspendWhenHidden = FALSE)

    state
}

plotModelRunResults <- function(output, state) {
    output$outputs_totalNumberOfTests <- renderPlot({
        plotTotalNumberOfTests(state$fp, state$mod, state$likdat)
    })

    output$outputs_numberOfPositiveTests <- renderPlot({
        plotNumberOfPositiveTests(state$fp, state$mod, state$likdat)
    })

    output$outputs_percentageNegativeOfTested <- renderPlot({
        plotPercentageNegativeOfTested(state$surveyAsDataTable, state$out_evertest)
    })

    output$outputs_percentagePLHIVOfTested <- renderPlot({
        plotPercentagePLHIVOfTested(state$surveyAsDataTable, state$out_evertest)
    })

    output$outputs_percentageTested <- renderPlot({
        plotPercentageTested(state$surveyAsDataTable, state$out_evertest)
    })

    output$outputs_firstAndSecond90 <- renderPlot({
        plotFirstAndSecond90(state$fp, state$mod, state$out_evertest)
    })
}