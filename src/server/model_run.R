modelRun <- function(input, output, state, spectrumFilesState, surveyAndProgramData) {
    output$modelRunState <- shiny::reactive({ state$state })
    shiny::outputOptions(output, "modelRunState", suspendWhenHidden = FALSE)

    state$showAdvancedOptions <- FALSE
    output$showAdvancedOptions <- shiny::reactive({ state$showAdvancedOptions })

    shiny::observeEvent(input$showAdvancedOptions, {
        state$showAdvancedOptions <- !state$showAdvancedOptions
    })

    shiny::outputOptions(output, "showAdvancedOptions", suspendWhenHidden = FALSE)

    # the model fitting code expects survey data as a data table and program data as a data frame
    # it could presumably be re-written to deal with survey data as a data frame but for now we're just
    # converting survey data to the expected format
    state$surveyAsDataTable <- shiny::reactive({
        if (is.null(surveyAndProgramData$survey)) {
            NULL
        } else {
            dt <- data.table::as.data.table(surveyAndProgramData$survey, keep.rownames = TRUE)
            dt$ci_l = dt$ci_l/100
            dt$ci_u = dt$ci_u/100
            dt$est = dt$est/100
            dt$se = dt$se/100
            dt$outcome = "evertest"

            dt
        }
    })

    # Likelihood
    state$likelihood <- shiny::reactive({
        tryCatch({
            ageGroup <- c('15-24','25-34','35-49')
            preparedSurveyData <- first90::select_hts(state$surveyAsDataTable(), spectrumFilesState$country, ageGroup)
            first90::prepare_hts_likdat(
                preparedSurveyData,
                surveyAndProgramData$program_data,
                spectrumFilesState$combinedData()
            )
        }, error = function(e) {
            print(glue::glue("An error occured calculating likelihood: {e}"))
            NULL
        })
    })

    # Run the model and the simulations
    shiny::observeEvent(input$runModel, {

        state$optim <- tryCatch({
            opt <- fitModel(input$maxIterations, state$likelihood(), spectrumFilesState$combinedData())
            if (opt$convergence == 0 || testMode){
                state$state <- "converged"
            }
            else {
                setError(state,"The model failed to converge. Please try increasing the maximum iterations allowed under 'advanced options'.")
            }
            opt
        }, error = function(e) {
            str(e)
            setError(state,"Model fitting failed. Please check your input data.")
        })

        if (state$state == "converged" && !is.na(input$numSimul) && input$numSimul > 0){

            state$optim$hessian <- tryCatch({
                calculateHessian(state$optim, state$likelihood(), spectrumFilesState$combinedData())
            }, error = function(e) {
                str(e)
                setError(state, "Calculating the Hessian matrix failed. Please check your input data.")
            })

            state$simul <- tryCatch({
                runSimulations(state$optim, state$likelihood(), spectrumFilesState$combinedData(), input$numSimul, state)
            }, error = function(e) {
                str(e)
                setError(state, "Running simulations failed. Please check your input data.")
            })
        }

        surveyAndProgramData$touched <- FALSE
        spectrumFilesState$touched <- FALSE

    })

    renderOutputs(input, output, state, spectrumFilesState)

    state <- invalidateOutputsWhenInputsChange(state, surveyAndProgramData, spectrumFilesState)

    output$modelRunError <- shiny::reactive({
        state$errorMessage
    })

    state
}

setError <- function(state, message){
    state$state <- "error"
    state$errorMessage <- message
}

renderOutputs <- function(input, output, state, spectrumFilesState) {
    # Plot the results
    shiny::observeEvent(state$optim, ignoreNULL = FALSE, {
        if (state$state == "converged" && !is.null(state$optim)) {
            tryCatch({
                # model fit results
                state$fp <- first90::create_hts_param(state$optim$par, spectrumFilesState$combinedData())
                state$mod <- first90::simmod(state$fp)

                # model output
                out_evertest = first90::get_out_evertest(state$mod, state$fp)

                # output for Spectrum re-ingestion
                state$spectrum_outputs <- first90::spectrum_output_table(state$mod, state$fp)

                plotModelRunResults(output, state$surveyAsDataTable(), state$likelihood(),
                                    state$fp, state$mod, spectrumFilesState$country, out_evertest, state$simul, state)

            }, error = function(e) {
                str(e)
                setError(state,"Plotting results failed. Please check your input data.")
            })
        }
        else {
            state$spectrum_outputs <- NULL
        }
    })

    # Render tables of results
    output$outputs_table_ever_tested <- renderModelResultsTable(state, function(state) {

        rbindlist(lapply(input$ever_test_status, function(status) {
            rbindlist(lapply(input$ever_test_sex, function(sex) {
                rbindlist(lapply(input$ever_test_agegr, function(age) {
                    first90::tab_out_evertest(state$mod, state$fp, age_grp = age, simul = state$simul, hiv = status, gender = sex)
                }))
            }))
        }))
    })
    output$outputs_table_aware <- renderModelResultsTable(state, function(state) {
        rbindlist(lapply(input$aware_status, function(status) {
            rbindlist(lapply(input$aware_sex, function(sex) {
                rbindlist(lapply(input$aware_agegr, function(age) {
                    first90::tab_out_aware(state$mod, state$fp, simul = state$simul, age_grp = age, gender = sex)
                }))
            }))
        }))
    })
    output$outputs_table_art_coverage <- renderModelResultsTable(state, function(state) {

        rbindlist(lapply(input$art_coverage_sex, function(sex) {
            rbindlist(lapply(input$art_coverage_agegr, function(age) {
                first90::tab_out_artcov(state$mod, state$fp, age_grp = age, gender = sex)
            }))
        }))
    })
}

invalidateOutputsWhenInputsChange <- function(state, surveyAndProgramData, spectrumFilesState) {
    invalidateOutputs <- function() {
        state$state <- "stale"
        state$optim <- NULL
        state$simul <- NULL
    }

    shiny::observeEvent(surveyAndProgramData$touched,  {
        str("survey/program")
        str(surveyAndProgramData$touched)
        if (surveyAndProgramData$touched){
            invalidateOutputs()
        }
    })

    shiny::observeEvent(spectrumFilesState$touched, {
        str("spectrum")
        str(surveyAndProgramData$touched)
        if (spectrumFilesState$touched){
            invalidateOutputs()
        }
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

plotModelRunResults <- function(output, surveyAsDataTable, likdat, fp, mod, country, out_evertest, simul, state) {
    output$outputs_totalNumberOfTests <- shiny::renderPlot({
        first90::plot_out_nbtest(mod, fp, likdat, country, simul)
    })

    output$outputs_numberOfPositiveTests <- shiny::renderPlot({
        first90::plot_out_nbpostest(mod, fp, likdat, country, simul)
    })

    output$outputs_percentageNegativeOfTested <- shiny::renderPlot({
        first90::plot_out_evertestneg(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    })

    output$outputs_percentagePLHIVOfTested <- shiny::renderPlot({
        first90::plot_out_evertestpos(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    })

    output$outputs_percentageTested <- shiny::renderPlot({
        first90::plot_out_evertest(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    })

    output$outputs_firstAndSecond90 <- shiny::renderPlot({
        first90::plot_out_90s(mod, fp, likdat, country, out_evertest, simul)
    })

    output$outputs_womenEverTested <- shiny::renderPlot({
        first90::plot_out_evertest_fbyage(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    })

    output$outputs_menEverTested <- shiny::renderPlot({
        first90::plot_out_evertest_mbyage(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    })

    output$outputs_advanced_params <- renderModelResultsTable(state, function(state) {
        first90::optimized_par(state$optim)
    })

    output$outputs_prv_pos_yld <- shiny::renderPlot({
        first90::plot_prv_pos_yld(mod, fp, likdat, country, yr_pred = 2018)
    })

    output$outputs_retest_neg <- shiny::renderPlot({
        first90::plot_retest_test_neg(mod, fp, likdat, country)
    })

    output$outputs_retest_pos <- shiny::renderPlot({
        first90::plot_retest_test_pos(mod, fp, likdat, country)
    })

    output$outputs_tab_out_pregprev <- renderModelResultsTable(state, function(state) {
        first90::tab_out_pregprev(mod, fp)
    })

}
