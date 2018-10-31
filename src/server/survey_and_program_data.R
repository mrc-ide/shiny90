library(magrittr)

as.num = function(x) {

    x[x == "NA"] <- NA

    if (is.factor(x)){
        x = as.character(x)
    }

    as.numeric(x)
}

mapColumnToNumeric <- function(dataframe, key) {
    dataframe[[key]] = as.num(dataframe[[key]])
    dataframe
}

mapColumnsToNumeric <- function(dataframe, colnames) {

    for (key in colnames){
        dataframe <- mapColumnToNumeric(dataframe, key)
    }
    dataframe
}

mapHeaders <- function(dataframe, from, to) {
    i <- match(from, names(dataframe))
    j <- !is.na(i)
    names(dataframe)[i[j]] <- to[j]
    dataframe
}

mapHeadersToHumanReadable <- function(dataframe, headers) {
    mapHeaders(dataframe, names(headers), unname(headers))
}

mapHeadersFromHumanReadable <- function(dataframe, headers) {
    mapHeaders(dataframe, unname(headers), names(headers))
}

sharedHeaders <- list(country= "Country",
                        year= "Year",
                        hivstatus= "HIV Status",
                        sex= "Sex",
                        agegr= "Age Group")

surveyDataHeaders <- list(surveyid="Survey Id",
                            outcome = "Outcome",
                            counts = "Counts",
                            est= "Estimate",
                            se= "Standard Error",
                            ci_l= "Lower Confidence Interval",
                            ci_u= "Upper Confidence Interval")

programDataHeaders <- list(tot= "Total tests",
                            totpos= "Total positive tests",
                            vct= "Total HTS tests",
                            vctpos= "Total positive HTS tests",
                            anc= "Total ANC tests",
                            ancpos= "Total positive ANC tests"
)

castToNumeric <- function(dataframe, headers){
    mapColumnsToNumeric(dataframe, names(headers))
}

surveyAndProgramData <- function(input, output, state, spectrumFilesState) {
    data("survey_hts", package="first90")
    data("prgm_dat", package="first90")

    state$loadNewData <- TRUE

    shiny::observeEvent(spectrumFilesState$country, {

        if (!is.null(spectrumFilesState$country)){
            if (state$loadNewData){
                state$survey <- as.data.frame(survey_hts)
                state$survey <- state$survey[state$survey$country == spectrumFilesState$country & state$survey$outcome == "evertest", ]
                state$survey$counts = as.integer(state$survey$counts)
                state$program_data <- castToNumeric(first90::select_prgmdata(prgm_dat, spectrumFilesState$country, NULL), programDataHeaders)
            }
            else {
                state$loadNewData <- TRUE
            }
        }
    })

    state$program_data_human_readable <- shiny::reactive({
        mapHeadersToHumanReadable(state$program_data, c(programDataHeaders,sharedHeaders))
    })

    state$survey_data_human_readable <- shiny::reactive({
        mapHeadersToHumanReadable(state$survey, c(surveyDataHeaders,sharedHeaders))
    })

    state$anyProgramData <- shiny::reactive({ !is.null(state$program_data) && nrow(state$program_data) > 0 })

    state$anyProgramDataTot <- shiny::reactive({ !is.null(state$program_data) && !all(is.na(state$program_data$tot)) })
    state$anyProgramDataTotPos <- shiny::reactive({ !is.null(state$program_data) && !all(is.na(state$program_data$totpos)) })
    state$anyProgramDataAnc <- shiny::reactive({ !is.null(state$program_data) && !all(is.na(state$program_data$anc)) })
    state$anyProgramDataAncPos <- shiny::reactive({ !is.null(state$program_data) && !all(is.na(state$program_data$ancpos)) })

    output$incompleteProgramData <- shiny::reactive({ !state$anyProgramDataTot() || !state$anyProgramDataTotPos() })

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
        rhandsontable::rhandsontable(state$survey_data_human_readable(), rowHeaders = NULL, stretchH = "all") %>%
            rhandsontable::hot_col("Country", readOnly = TRUE) %>%
            rhandsontable::hot_col("Outcome", allowInvalid = TRUE) %>%
            rhandsontable::hot_col("Age Group", allowInvalid = TRUE)  %>%
            rhandsontable::hot_col("Estimate", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Standard Error", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Lower Confidence Interval", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Upper Confidence Interval", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Year", type="numeric", format = "0")
    })

    output$hot_program <- rhandsontable::renderRHandsontable({
        rhandsontable::rhandsontable(state$program_data_human_readable(), rowHeaders = NULL, stretchH = "all") %>%
            rhandsontable::hot_col("Country", readOnly = TRUE) %>%
            rhandsontable::hot_col("Total tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total positive tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total HTS tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total positive HTS tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total ANC tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total positive ANC tests", type="numeric", renderer = number_renderer)
    })

    shiny::observeEvent(input$surveyData, {
        inFile <- input$surveyData

        if (is.null(inFile)){
            return(NULL)
        }

        newSurvey <- read.csv(inFile$datapath, check.names=FALSE)

        state$wrongSurveyHeaders <<- !identical(sort(names(newSurvey)), sort(names(state$survey_data_human_readable())))

        state$wrongSurveyCountry <<- !state$wrongSurveyHeaders && nrow(subset(newSurvey, gsub("\t", "", Country) == spectrumFilesState$country)) < nrow(newSurvey)

        if (!state$wrongSurveyHeaders && !state$wrongSurveyCountry){
            state$survey <<- mapHeadersFromHumanReadable(newSurvey, c(surveyDataHeaders, sharedHeaders))
        }

        shinyjs::reset("surveyData")

    })

    shiny::observeEvent(input$programData, {
        inFile <- input$programData

        if (is.null(inFile)){
            return(NULL)
        }
        
        newProgram <- read.csv(inFile$datapath, check.names=FALSE)

        state$wrongProgramHeaders <<- !identical(sort(names(newProgram)), sort(names(state$program_data_human_readable())))

        state$wrongProgramCountry <<- !state$wrongProgramHeaders && nrow(subset(newProgram, gsub("\t", "", Country) == spectrumFilesState$country)) < nrow(newProgram)

        if (!state$wrongProgramHeaders && !state$wrongProgramCountry){
            state$program_data <<- castToNumeric(mapHeadersFromHumanReadable(newProgram, c(programDataHeaders, sharedHeaders)), programDataHeaders)
        }

        shinyjs::reset("programData")
    })

    # We track change events so that we know when to reset the model run state.
    # See comment in model_run.R
    state$surveyTableChanged <- 0
    state$programTableChanged <- 0

    shiny::observeEvent(input$hot_survey, {
        if(!is.null(input$hot_survey)){
            state$survey <<- mapHeadersFromHumanReadable(rhandsontable::hot_to_r(input$hot_survey), c(surveyDataHeaders, sharedHeaders))
            state$surveyTableChanged <<- state$surveyTableChanged + 1
        }
    })

    shiny::observeEvent(input$hot_program, {
        if(!is.null(input$hot_program)){
            state$program_data <<- mapHeadersFromHumanReadable(rhandsontable::hot_to_r(input$hot_program), c(programDataHeaders,sharedHeaders))
            state$programTableChanged <<- state$programTableChanged + 1
        }
    })

    output$downloadSurveyTemplate <- downloadTemplate(state$survey_data_human_readable(),
                                                        glue::glue("survey-data-{spectrumFilesState$country}.csv"))
    output$downloadProgramTemplate <- downloadTemplate(state$program_data_human_readable(),
                                                        glue::glue("program-data-{spectrumFilesState$country}.csv"))

    state
}


downloadTemplate <- function(dataframe, filename) {

    shiny::downloadHandler(
        filename = filename,
            contentType = "text/csv",
            content = function(file) {
                write.csv(dataframe, file, row.names = FALSE)
            }
    )
}
