library(shiny)
library(first90)
library(promises)
library(future)
plan(multisession)

modelRun <- function(input, output, spectrumFilesState, surveyAndProgramData) {
    state <- reactiveValues()
    state$state <- "not_run"
    state$running <- FALSE
    state$surveyAsDataTable <- NULL
    state$out <- NULL
    state$likdat <- NULL
    state$fp <- NULL
    state$mod <- NULL
    state$out_evertest <- NULL

    output$modelRunning <- reactive({ state$running })
    output$modelRunState <- reactive({ state$state })

    state$out <- eventReactive(input$runModel, {
        state$running = TRUE
        state$state <- "running"

        # the model fitting code expects survey data as a data table and program data as a data frame
        # it could presumably be re-written to deal with survey data as a data frame but for now we're just
        # converting survey data to the expected format
        state$surveyAsDataTable <- as.data.table(surveyAndProgramData$survey, keep.rownames=TRUE)

        surveyData <- state$surveyAsDataTable
        programData <- surveyAndProgramData$program
        pjnzFilePath <- spectrumFilesState$pjnzFilePath
        future({
            fitModel(surveyData, programData, pjnzFilePath)
        })
    })

    state$out_evertest <- reactive({
        state$out %...>% {
            out <- .
            # model fit results
            state$likdat <- out$likdat
            state$fp <- out$fp
            state$mod <- eppasm::simmod.specfp(out$fp)

            # model output
            out_evertest <- outEverTest(state$fp, state$mod)

            state$state <- "finished"
            state$running <- FALSE

            out_evertest
        }
    })

    plotModelRunResults(output, state)
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