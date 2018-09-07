library(shiny)
library(first90)
library(purrr)

modelRun <- function(input, output, spectrumFilesState, surveyAndProgramData) {
    state <- reactiveValues()
    state$state <- "not_run"

    observeEvent(input$runModel, {

        # the model fitting code expects survey data as a data table and program data as a data frame
        # it could presumably be re-written to deal with survey data as a data frame but for now we're just
        # converting survey data to the expected format
        surveyAsDataTable <- as.data.table(surveyAndProgramData$survey, keep.rownames=TRUE)

        out <- fitModel(surveyAsDataTable, surveyAndProgramData$program, spectrumFilesState$combinedData())

        # model fit results
        likdat <- out$likdat
        fp <- out$fp
        mod <- eppasm::simmod.specfp(fp)

        # model output
        out_evertest = outEverTest(fp, mod)

        plotModelRunResults(output, surveyAsDataTable, likdat, fp, mod, out_evertest)

        state$state <- "finished"
    })

    output$modelRunState <- reactive({ state$state })
    outputOptions(output, "modelRunState", suspendWhenHidden = FALSE)

    state
}

plotModelRunResults <- function(output, surveyAsDataTable, likdat, fp, mod, out_evertest) {
    output$outputs_totalNumberOfTests <- renderPlot({
        plotTotalNumberOfTests(fp, mod, likdat)
    })

    output$outputs_numberOfPositiveTests <- renderPlot({
        plotNumberOfPositiveTests(fp, mod, likdat)
    })

    output$outputs_percentageNegativeOfTested <- renderPlot({
        plotPercentageNegativeOfTested(surveyAsDataTable, out_evertest)
    })

    output$outputs_percentagePLHIVOfTested <- renderPlot({
        plotPercentagePLHIVOfTested(surveyAsDataTable, out_evertest)
    })

    output$outputs_percentageTested <- renderPlot({
        plotPercentageTested(surveyAsDataTable, out_evertest)
    })

    output$outputs_firstAndSecond90 <- renderPlot({
        plotFirstAndSecond90(fp, mod, out_evertest)
    })
}