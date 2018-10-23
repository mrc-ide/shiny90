library(magrittr)

as.num = function(x) {
    if (is.factor(x)){
        x = as.character(x)
    }

    as.numeric(x)
}

castProgramDataToNumeric <- function(state){
    state$program_data$tot = as.num(state$program_data$tot)
    state$program_data$totpos = as.num(state$program_data$totpos)
    state$program_data$vct = as.num(state$program_data$vct)
    state$program_data$vctpos = as.num(state$program_data$vctpos)
    state$program_data$anc = as.num(state$program_data$anc)
    state$program_data$ancpos = as.num(state$program_data$ancpos)
}

surveyAndProgramData <- function(input, output, state, spectrumFilesState) {
    data("survey_hts", package="first90")
    data("prgm_dat", package="first90")

    shiny::observeEvent(spectrumFilesState$country, {

        if (!is.null(spectrumFilesState$country)){
            state$survey <- as.data.frame(survey_hts)
            state$survey <- state$survey[state$survey$country == spectrumFilesState$country & state$survey$outcome == "evertest", ]
            state$program_data <- first90::select_prgmdata(prgm_dat, spectrumFilesState$country, NULL)
            castProgramDataToNumeric(state)
        }
    })

    state$anyProgramData <- shiny::reactive({ !is.null(state$program_data) && nrow(state$program_data) > 0 })

    state$anyProgramDataTot <- shiny::reactive({ !is.null(state$program_data) && !all(is.na(state$program_data$tot)) })
    state$anyProgramDataTotPos <- shiny::reactive({ !is.null(state$program_data) && !all(is.na(state$program_data$totpos)) })
    state$anyProgramDataAnc <- shiny::reactive({ !is.null(state$program_data) && !all(is.na(state$program_data$anc)) })
    state$anyProgramDataAncPos <- shiny::reactive({ !is.null(state$program_data) && !all(is.na(state$program_data$ancpos)) })

    output$incompleteProgramData <- shiny::reactive({ !state$anyProgramDataTot() || !state$anyProgramDataTotPos() ||
        !state$anyProgramDataAnc() || !state$anyProgramDataAncPos()})

    output$anyProgramDataTot <- shiny::reactive({ state$anyProgramDataTot() })
    output$anyProgramDataTotPos <- shiny::reactive({ state$anyProgramDataTotPos() })
    output$anyProgramDataAnc <- shiny::reactive({ state$anyProgramDataAnc() })
    output$anyProgramDataAncPos <- shiny::reactive({ state$anyProgramDataAncPos() })

    output$wrongSurveyHeaders <- shiny::reactive({ state$wrongSurveyHeaders })
    output$wrongSurveyCountry <- shiny::reactive({ state$wrongSurveyCountry })
    output$wrongProgramHeaders <- shiny::reactive({ state$wrongProgramHeaders })
    output$wrongProgramCountry <- shiny::reactive({ state$wrongProgramCountry })

    shiny::outputOptions(output, "incompleteProgramData", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "anyProgramDataTot", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "anyProgramDataTotPos", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "anyProgramDataAnc", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "anyProgramDataAncPos", suspendWhenHidden = FALSE)

    shiny::outputOptions(output, "wrongSurveyHeaders", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "wrongSurveyCountry", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "wrongProgramHeaders", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "wrongProgramCountry", suspendWhenHidden = FALSE)

    number_renderer = "function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.textAlign = 'right';
        }"

    output$hot_survey <- rhandsontable::renderRHandsontable({
        rhandsontable::rhandsontable(state$survey, rowHeaders = NULL, stretchH = "all") %>%
            rhandsontable::hot_col("country", readOnly = TRUE) %>%
            rhandsontable::hot_col("outcome", allowInvalid = TRUE) %>%
            rhandsontable::hot_col("agegr", allowInvalid = TRUE)  %>%
            rhandsontable::hot_col("est", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("se", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("ci_l", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("ci_u", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("year", type="numeric", format = "0")
    })

    output$hot_program <- rhandsontable::renderRHandsontable({
        rhandsontable::rhandsontable(state$program_data, rowHeaders = NULL, stretchH = "all") %>%
            rhandsontable::hot_col("country", readOnly = TRUE) %>%
            rhandsontable::hot_col("tot", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("totpos", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("vct", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("vctpos", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("anc", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("ancpos", type="numeric", renderer = number_renderer)
    })

    shiny::observeEvent(input$surveyData, {
        inFile <- input$surveyData

        if (is.null(inFile)){
            return(NULL)
        }

        newSurvey <- read.csv(inFile$datapath)

        state$wrongSurveyHeaders <<- !identical(sort(names(newSurvey)), sort(names(state$survey)))

        state$wrongSurveyCountry <<- !state$wrongSurveyHeaders && nrow(subset(newSurvey, gsub("\t", "", country) == spectrumFilesState$country)) < nrow(newSurvey)

        if (!state$wrongSurveyHeaders && !state$wrongSurveyCountry){
            state$survey <<- newSurvey
        }

    })

    shiny::observeEvent(input$programData, {
        inFile <- input$programData

        if (is.null(inFile)){
            return(NULL)
        }
        
        newProgram <- read.csv(inFile$datapath)

        state$wrongProgramHeaders <<- !identical(sort(names(newProgram)), sort(names(state$program_data)))

        state$wrongProgramCountry <<- !state$wrongProgramHeaders && nrow(subset(newProgram, gsub("\t", "", country) == spectrumFilesState$country)) < nrow(newProgram)

        if (!state$wrongProgramHeaders && !state$wrongProgramCountry){
            state$program_data <<- newProgram
            castProgramDataToNumeric(state)
        }
    })

    # We track change events so that we know when to reset the model run state.
    # See comment in model_run.R
    state$surveyTableChanged <- 0
    state$programTableChanged <- 0

    shiny::observeEvent(input$hot_survey, {
        if(!is.null(input$hot_survey)){
            state$survey <<- rhandsontable::hot_to_r(input$hot_survey)
            state$surveyTableChanged <<- state$surveyTableChanged + 1
        }
    })

    shiny::observeEvent(input$hot_program, {
        if(!is.null(input$hot_program)){
            state$program_data <<- rhandsontable::hot_to_r(input$hot_program)
            state$programTableChanged <<- state$programTableChanged + 1
        }
    })

    state
}
