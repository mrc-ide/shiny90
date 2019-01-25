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

castToNumeric <- function(dataframe, headers){
    mapColumnsToNumeric(dataframe, names(headers))
}

removeTabs <- function(name) {
    gsub("\t", "", name)
}

createEmptySurveyData <- function(countryAndRegionName) {
    data.frame(country=countryAndRegionName,
                surveyid=rep(as.character(NA), 1),
                year=rep(NA_integer_, 1),
                agegr=rep(as.character(NA), 1),
                sex=rep(as.character(NA), 1),
                hivstatus=rep(as.character(NA), 1),
                est=rep(NA_real_, 1),
                se=rep(NA_real_, 1),
                ci_l=rep(NA_real_, 1),
                ci_u=rep(NA_real_, 1),
                counts=rep(NA_integer_, 1))
}

anySurveyData <- function(df) {
    !is.null(df) && nrow(df) > 0 && all(!is.na(df$surveyid))
}

surveyAndProgramData <- function(input, output, state, spectrumFilesState) {

    state$touched <- FALSE
    state$loadNewData <- TRUE

    shiny::observeEvent(spectrumFilesState$dataSets, {

        if (!is.null(spectrumFilesState$countryAndRegionName())){
            if (state$loadNewData){
                state$survey <- createEmptySurveyData(spectrumFilesState$countryAndRegionName())
                state$program_data <- castToNumeric(first90::select_prgmdata(NULL, spectrumFilesState$countryAndRegionName(), NULL), programDataHeaders)
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
    state$anySurveyData <- shiny::reactive({ anySurveyData(state$survey) })

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
            rhandsontable::hot_col("Country or region", readOnly = TRUE) %>%
            rhandsontable::hot_col("Age Group", allowInvalid = TRUE)  %>%
            rhandsontable::hot_col("Estimate", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Standard Error", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Lower Confidence Interval", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Upper Confidence Interval", type="numeric", renderer = number_renderer) %>%
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
            rhandsontable::hot_col("Total Positive ANC Tests", type="numeric", renderer = number_renderer)
    })

    shiny::observeEvent(input$surveyData, {
        inFile <- input$surveyData

        if (is.null(inFile)){
            return(NULL)
        }

        newSurvey <- read.csv(inFile$datapath, check.names=FALSE)

        state$wrongSurveyHeaders <- !identical(sort(names(newSurvey)), sort(names(state$survey_data_human_readable())))

        state$wrongSurveyCountry <- !state$wrongSurveyHeaders &&
        nrow(newSurvey[removeTabs(newSurvey[["Country or region"]]) == removeTabs(spectrumFilesState$countryAndRegionName()), ]) < nrow(newSurvey)

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

        state$wrongProgramCountry <- !state$wrongProgramHeaders && nrow(newProgram[removeTabs(newProgram[["Country or region"]]) == removeTabs(spectrumFilesState$countryAndRegionName()), ]) < nrow(newProgram)

        if (!state$wrongProgramHeaders && !state$wrongProgramCountry){
            state$program_data <- castToNumeric(mapHeadersFromHumanReadable(newProgram, c(programDataHeaders, sharedHeaders)), programDataHeaders)
            state$touched <- TRUE
        }

        shinyjs::reset("programData")
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

    shiny::observeEvent(spectrumFilesState$countryAndRegionName(), {
        output$downloadSurveyTemplate <- downloadTemplate(state$survey_data_human_readable, templateFileName("survey"))
        output$downloadProgramTemplate <- downloadTemplate(state$program_data_human_readable, templateFileName("program"))
    })
    
    state
}

templateFileName <- function(dataType) {
    gsub(" ", "", glue::glue("{dataType}-data-{spectrumFilesState$countryAndRegionName()}.csv"), fixed=TRUE)
}

downloadTemplate <- function(dataframe, filename) {

    shiny::downloadHandler(
        filename =  filename,
            contentType = "text/csv",
            content = function(file) {
                write.csv(dataframe(), file, row.names = FALSE, na = "")
            }
    )
}
