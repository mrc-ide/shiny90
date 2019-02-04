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

castToNumeric <- function(dataframe, headers){
    mapColumnsToNumeric(dataframe, names(headers))
}

mapHeaders <- function(dataframe, from, to) {
    i <- match(from, names(dataframe))
    j <- !is.na(i)
    names(dataframe)[i[j]] <- to[j]
    dataframe
}

importProgramData <- function(newProgramData) {
    newProgramData <- mapHeadersFromHumanReadable(newProgramData, c(programDataHeaders, sharedHeaders))
    newProgramData <- castToNumeric(newProgramData, programDataHeaders)
    newProgramData$sex <- tolower(newProgramData$sex)
    newProgramData
}

mapHeadersToHumanReadable <- function(dataframe, headers) {
    mapHeaders(dataframe, names(headers), unname(headers))
}

mapHeadersFromHumanReadable <- function(dataframe, headers) {
    mapHeaders(dataframe, unname(headers), names(headers))
}

sharedHeaders <- list(country= "Country or region",
                        year= "Year",
                        sex= "Sex")

surveyDataHeaders <- list(surveyid="Survey Id",
                            hivstatus= "HIV Status",
                            outcome = "Outcome",
                            agegr= "Age Group",
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

validateProgramData <- function(df, countryAndRegionName) {

    if (is.null(df))
        return(FALSE)

    validateRow <- function(givenYear) {

        rows <- df[which(df$year == givenYear),]

        validSex <- nrow(rows) == 0 ||
                    identical(as.character(rows$sex),c("both")) ||
                    identical(sort(as.character(rows$sex)), sort(c("male", "female")))

        validCountry <- all(as.character(rows$country) == countryAndRegionName)

        validSex && validCountry
    }

    result <- lapply(df$year, validateRow)
    all(result == TRUE)
}

validateSurveyData <- function(df, countryAndRegionName) {
  !is.null(df) && 
    nrow(df) > 0 && 
    all(c("surveyid", "country") %in% names(df)) &&
    all(!is.na(df$surveyid)) && 
    all(df$country == countryAndRegionName)
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
                counts=rep(NA_integer_, 1),
                stringsAsFactors = FALSE)
}

createEmptyProgramData <- function(countryAndRegionName) {
    data.frame(country = countryAndRegionName,
                year = 2010:2018,
                sex = 'both',
                tot = NA_integer_,
                totpos = NA_integer_,
                vct = NA_integer_,
                vctpos = NA_integer_,
                anc = NA_integer_,
                ancpos = NA_integer_,
                stringsAsFactors = FALSE)
}

surveyAndProgramData <- function(input, output, state, spectrumFilesState) {

    state$touched <- FALSE
    state$loadNewData <- TRUE

    shiny::observeEvent(spectrumFilesState$dataSets, {

        if (!is.null(spectrumFilesState$countryAndRegionName())){
            if (state$loadNewData){
                state$survey <- createEmptySurveyData(spectrumFilesState$countryAndRegionName())
                state$program_data <- createEmptyProgramData(spectrumFilesState$countryAndRegionName())
            }
            else {
                state$loadNewData <- TRUE
            }
        }
    })

    state$programDataValid <- shiny::reactive({
        validateProgramData(state$program_data, spectrumFilesState$countryAndRegionName())
    })
    
    state$surveyDataValid <- shiny::reactive({
      validateSurveyData(state$survey, spectrumFilesState$countryAndRegionName())
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

    output$invalidSurveyData <- shiny::reactive({ !state$surveyDataValid() })
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

    shiny::outputOptions(output, "invalidSurveyData", suspendWhenHidden = FALSE)
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
            rhandsontable::hot_col("Country or region") %>%
            rhandsontable::hot_col("Age Group", type = "dropdown", source = c("15-24", "25-34", "35-49", "50+", "15-49", "15+"))  %>%
            rhandsontable::hot_col("Estimate", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Standard Error", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Lower Confidence Interval", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Upper Confidence Interval", type="numeric", renderer = number_renderer) %>%
            rhandsontable::hot_col("Year", type="numeric", format = "0") %>%
            rhandsontable::hot_col("Sex", type = "dropdown", source = c("both", "female", "male")) %>%
            rhandsontable::hot_col("HIV Status", type = "dropdown", source = c("positive", "negative", "all"))
    })

    output$hot_program <- rhandsontable::renderRHandsontable({
        rhandsontable::rhandsontable(state$program_data_human_readable(), rowHeaders = NULL, stretchH = "all") %>%
            rhandsontable::hot_col("Country or region") %>%
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

        newSurvey <- read.csv(inFile$datapath, check.names=FALSE, stringsAsFactors = FALSE)

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

        newProgramData <- read.csv(inFile$datapath, check.names=FALSE, stringsAsFactors = FALSE)

        state$wrongProgramHeaders <- !identical(sort(names(newProgramData)), sort(names(state$program_data_human_readable())))

        state$wrongProgramCountry <- !state$wrongProgramHeaders && nrow(newProgramData[removeTabs(newProgramData[["Country or region"]]) == removeTabs(spectrumFilesState$countryAndRegionName()), ]) < nrow(newProgramData)

        if (!state$wrongProgramHeaders && !state$wrongProgramCountry){
            state$program_data <- importProgramData(newProgramData)
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
        output$downloadSurveyTemplate <- downloadTemplate(state$survey_data_human_readable, templateFileName("survey", spectrumFilesState))
        output$downloadProgramTemplate <- downloadTemplate(state$program_data_human_readable, templateFileName("program", spectrumFilesState))
    })
    
    state
}

templateFileName <- function(dataType, spectrumFilesState) {
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
