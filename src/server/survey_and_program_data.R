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

sharedHeaders <- list(country= "Country or region",
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

programDataHeaders <- list(tot= "Total Tests",
                            totpos= "Total Positive Tests",
                            vct= "Total HTC Tests",
                            vctpos= "Total Positive HTC Tests",
                            anc= "Total ANC Tests",
                            ancpos= "Total Positive ANC Tests"
)

validateProgramData <- function(df) {

    if (is.null(df))
        return(FALSE)

    validateYear <- function(year) {

        rows <- df[!is.na(df$year) && df$year == year,]

        if (nrow(rows) == 0) return(TRUE)
        if (nrow(rows) > 2) return(FALSE)
        if (nrow(rows) == 1 && (as.character(rows$sex) == c("both"))) return(TRUE)
        if (nrow(rows) == 2 && sort(as.character(rows$sex)) == sort(c("male", "female"))) return(TRUE)

        FALSE
    }

    result <- lapply(seq(from=2010,to=2018,by = 1), validateYear)
    all(result == TRUE)
}

castToNumeric <- function(dataframe, headers){
    mapColumnsToNumeric(dataframe, names(headers))
}

removeSpecialChars <- function(name) {
    name <- gsub("\t", "", name)
    iconv(name, "UTF-8", "ASCII//TRANSLIT")
}

mapSurveyToInternalModel <- function(df, countryAndRegionName) {

    df <- df[removeSpecialChars(df$country) == removeSpecialChars(countryAndRegionName) & df$outcome == "evertest", ]

    df <- data.frame(df$country,
                    df$surveyid,
                    df$year,
                    df$agegr,
                    df$sex,
                    df$hivstatus,
                    df$est*100,
                    df$se*100,
                    df$ci_l*100,
                    df$ci_u*100,
                    as.integer(df$counts))

    colnames(df) <- c("country", "surveyid", "year", "agegr","sex", "hivstatus", "est", "se", "ci_l", "ci_u", "counts")

    df[with(df, order(df$year, df$agegr, df$sex, df$hivstatus)), ]
}

resetSurveyToDefaults <- function(state, country, countryAndRegionName) {
    state$survey <- as.data.frame(survey_hts)
    state$survey <- mapSurveyToInternalModel(as.data.frame(survey_hts), countryAndRegionName)
}

surveyAndProgramData <- function(input, output, state, spectrumFilesState) {
    data("survey_hts", package="first90")

    state$touched <- FALSE
    state$loadNewData <- TRUE

    shiny::observeEvent(spectrumFilesState$dataSets, {

        if (!is.null(spectrumFilesState$countryAndRegionName())){
            if (state$loadNewData){
                state$survey <- as.data.frame(survey_hts)
                state$survey <- mapSurveyToInternalModel(as.data.frame(survey_hts), spectrumFilesState$countryAndRegionName())
                state$program_data <- castToNumeric(first90::select_prgmdata(NULL, spectrumFilesState$countryAndRegionName(), NULL), programDataHeaders)
            }
            else {
                state$loadNewData <- TRUE
            }
        }
    })

    state$programDataValid <- shiny::reactive({
        validateProgramData(state$program_data)
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
    output$invalidProgramData <- shiny::reactive({ !state$programDataValid() })

    output$anyProgramDataTot <- shiny::reactive({ state$anyProgramDataTot() })
    output$anyProgramDataTotPos <- shiny::reactive({ state$anyProgramDataTotPos() })
    output$anyProgramDataAnc <- shiny::reactive({ state$anyProgramDataAnc() })
    output$anyProgramDataAncPos <- shiny::reactive({ state$anyProgramDataAncPos() })

    output$wrongSurveyHeaders <- shiny::reactive({ state$wrongSurveyHeaders })
    output$wrongSurveyCountry <- shiny::reactive({ state$wrongSurveyCountry })
    output$wrongProgramHeaders <- shiny::reactive({ state$wrongProgramHeaders })
    output$wrongProgramCountry <- shiny::reactive({ state$wrongProgramCountry })

    shiny::outputOptions(output, "incompleteProgramData", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "invalidProgramData", suspendWhenHidden = FALSE)

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
        rhandsontable::rhandsontable(state$survey_data_human_readable(),
        colHeaders = c("Country or region","Survey Id","Year","Age Group","Sex","HIV Status","Estimate (%)", "Standard Error (%)",
        "Lower Confidence Interval (%)",
        "Upper Confidence Interval (%)", "Counts"), rowHeaders = NULL, stretchH = "all") %>%
            rhandsontable::hot_col("Country or region", readOnly = TRUE) %>%
            rhandsontable::hot_col("Age Group", allowInvalid = TRUE)  %>%
            rhandsontable::hot_col("Estimate (%)", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Standard Error (%)", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Lower Confidence Interval (%)", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Upper Confidence Interval (%)", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Year", type="numeric", format = "0")
    })

    output$hot_program <- rhandsontable::renderRHandsontable({
        rhandsontable::rhandsontable(state$program_data_human_readable(), rowHeaders = NULL, stretchH = "all") %>%
            rhandsontable::hot_col("Country or region", readOnly = TRUE) %>%
            rhandsontable::hot_col("Total Tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total Positive Tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total HTC Tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total Positive HTC Tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total ANC Tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Total Positive ANC Tests", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Sex", type = "dropdown", source = c("both", "female", "male"))
    })

    shiny::observeEvent(input$surveyData, {
        inFile <- input$surveyData

        if (is.null(inFile)){
            return(NULL)
        }

        newSurvey <- read.csv(inFile$datapath, check.names=FALSE)

        state$wrongSurveyHeaders <- !identical(sort(names(newSurvey)), sort(names(state$survey_data_human_readable())))

        state$wrongSurveyCountry <- !state$wrongSurveyHeaders &&
        nrow(newSurvey[removeSpecialChars(newSurvey[["Country or region"]]) == removeSpecialChars(spectrumFilesState$countryAndRegionName()), ]) < nrow(newSurvey)

        if (!state$wrongSurveyHeaders && !state$wrongSurveyCountry){
            state$survey <- mapHeadersFromHumanReadable(newSurvey, c(surveyDataHeaders, sharedHeaders))
            state$touched <- TRUE
        }

        shinyjs::reset("surveyData")

    })

    shiny::observeEvent(input$programData, {
        inFile <- input$programData

        if (is.null(inFile)){
            return(NULL)
        }
        
        newProgram <- read.csv(inFile$datapath, check.names=FALSE)

        state$wrongProgramHeaders <- !identical(sort(names(newProgram)), sort(names(state$program_data_human_readable())))

        state$wrongProgramCountry <- !state$wrongProgramHeaders && nrow(newProgram[removeSpecialChars(newProgram[["Country or region"]]) == removeSpecialChars(spectrumFilesState$countryAndRegionName()), ]) < nrow(newProgram)

        if (!state$wrongProgramHeaders && !state$wrongProgramCountry){
            state$program_data <- castToNumeric(mapHeadersFromHumanReadable(newProgram, c(programDataHeaders, sharedHeaders)), programDataHeaders)
            state$touched <- TRUE
        }

        shinyjs::reset("programData")
    })

    shiny::observeEvent(input$resetSurveyData, {
        resetSurveyToDefaults(state, spectrumFilesState$country, spectrumFilesState$countryAndRegionName())
        state$touched <- TRUE
    })

    # We track change events so that we know when to reset the model run state.
    state$surveyTableChanged <- 0
    state$programTableChanged <- 0

    shiny::observeEvent(input$hot_survey, {
        if(!is.null(input$hot_survey)){
            state$survey <- mapHeadersFromHumanReadable(rhandsontable::hot_to_r(input$hot_survey), c(surveyDataHeaders, sharedHeaders))
            # for unknown reasons this event fires twice on first load
            # so only track changes after the first 2 changes
            if (state$surveyTableChanged > 1){
                state$touched <- TRUE
            }
            state$surveyTableChanged <- state$surveyTableChanged + 1
        }
    })

    shiny::observeEvent(input$hot_program, {
        if(!is.null(input$hot_program)){
            state$program_data <- mapHeadersFromHumanReadable(rhandsontable::hot_to_r(input$hot_program), c(programDataHeaders,sharedHeaders))
            # for unknown reasons this event fires twice on first load
            # so only track changes after the first 2 changes
            if (state$programTableChanged > 1){
                state$touched <- TRUE
            }
            state$programTableChanged <- state$programTableChanged + 1
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
                write.csv(dataframe, file, row.names = FALSE, na = "")
            }
    )
}
