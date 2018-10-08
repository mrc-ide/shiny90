library(magrittr)

surveyAndProgramData <- function(input, output, state, spectrumFilesState) {
    data("survey_hts", package="first90")
    data("prgm_dat", package="first90")

    shiny::observeEvent(spectrumFilesState$country, {

        if (!is.null(spectrumFilesState$country)){
            state$survey <- as.data.frame(survey_hts)
            state$survey <- state$survey[state$survey$country == spectrumFilesState$country & state$survey$outcome == "evertest", ]
            state$program_data <- first90::select_prgmdata(prgm_dat, spectrumFilesState$country, NULL)
        }
    })

    state$anyProgramData <- shiny::reactive({ !is.null(state$program_data) && nrow(state$program_data %>% na.omit()) > 0 })

    output$noProgramData <- shiny::reactive({ !state$anyProgramData() })

    output$wrongSurveyHeaders <- shiny::reactive({ state$wrongSurveyHeaders })
    output$wrongSurveyCountry <- shiny::reactive({ state$wrongSurveyCountry })
    output$wrongProgramHeaders <- shiny::reactive({ state$wrongProgramHeaders })
    output$wrongProgramCountry <- shiny::reactive({ state$wrongProgramCountry })

    shiny::outputOptions(output, "noProgramData", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "wrongSurveyHeaders", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "wrongSurveyCountry", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "wrongProgramHeaders", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "wrongProgramCountry", suspendWhenHidden = FALSE)

    number_renderer = "function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.textAlign = 'right';
        }"

    output$hot_survey <- rhandsontable::renderRHandsontable({
        rhandsontable::rhandsontable(state$survey, stretchH = "all") %>%
            rhandsontable::hot_col("country", readOnly = TRUE) %>%
            rhandsontable::hot_col("outcome", allowInvalid = TRUE) %>%
            rhandsontable::hot_col("agegr", allowInvalid = TRUE)  %>%
            rhandsontable::hot_col("est", renderer = number_renderer) %>%
            rhandsontable::hot_col("se", renderer = number_renderer) %>%
            rhandsontable::hot_col("ci_l", renderer = number_renderer) %>%
            rhandsontable::hot_col("ci_u", renderer = number_renderer) %>%
            rhandsontable::hot_col("year", format = "0")
    })

    output$hot_program <- rhandsontable::renderRHandsontable({
        rhandsontable::rhandsontable(state$program_data, stretchH = "all") %>%
            rhandsontable::hot_col("country", readOnly = TRUE) %>%
            rhandsontable::hot_col("tot", renderer = number_renderer) %>%
            rhandsontable::hot_col("totpos", renderer = number_renderer) %>%
            rhandsontable::hot_col("vct", renderer = number_renderer) %>%
            rhandsontable::hot_col("vctpos", renderer = number_renderer) %>%
            rhandsontable::hot_col("anc", renderer = number_renderer) %>%
            rhandsontable::hot_col("ancpos", renderer = number_renderer)
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
