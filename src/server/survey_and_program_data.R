library(tidyr)
library(shiny)
library(data.table)
library(rhandsontable)
library(first90)

getProgramDataInWideFormat <- function(country) {
    data(prgm_dat)
    long <- prgm_dat[prgm_dat$country == country, ]
    long$country <- NULL
    long$notes <- NULL

    if (nrow(long) == 0) {

        # we create an empty data table here, but the plots require values, so we shouldn't let the user proceed
        # unless they have at least one non-empty row
        years <- seq(2005, 2017)
        NbTested <- as.numeric(rep(NA, 2018-2005))
        NbTestPos <- as.numeric(rep(NA, 2018-2005))
        NbANCTested <- as.numeric(rep(NA, 2018-2005))
        NBTestedANCPos <- as.numeric(rep(NA, 2018-2005))

        wide <- data.frame(years, NbTested, NbTestPos, NbANCTested, NBTestedANCPos)
        colnames(wide) <- c("year", "NbTested", "NbTestPos", "NbANCTested", "NBTestedANCPos")
    }
    else {
        wide <- spread(long, key = "type", value = "number")
    }

    wide[c("year", "NbTested", "NbTestPos", "NbANCTested", "NBTestedANCPos")]
}

surveyAndProgramData <- function(input, output, state, spectrumFilesState) {
    data(survey_hts)
    data(prgm_dat)

    state$program_wide <- data.frame(year=integer(),
                                        NbTested=numeric(),
                                        NbTestPos = numeric(),
                                        NbANCTested=numeric(),
                                        NBTestedANCPos=numeric())

    observeEvent(spectrumFilesState$country, {
        state$survey <- as.data.frame(survey_hts[country == spectrumFilesState$country & outcome == "evertest"])
        state$program_wide <- getProgramDataInWideFormat(spectrumFilesState$country)
    })
    state$program <- reactive({
        gather(state$program_wide,
            key = "type", value = "number",
            "NbTested", "NbTestPos", "NbANCTested", "NBTestedANCPos"
        )
    })

    state$anyProgramData <- reactive({ nrow(state$program_wide %>% na.omit()) > 0 })

    output$noProgramData <- reactive({ !state$anyProgramData() })

    outputOptions(output, "noProgramData", suspendWhenHidden = FALSE)

    number_renderer = "function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.textAlign = 'right';
        }"

    output$hot_survey <- renderRHandsontable({
        rhandsontable(state$survey, stretchH = "all") %>%
        hot_col("outcome", allowInvalid = TRUE) %>%
        hot_col("agegr", allowInvalid = TRUE)  %>%
        hot_col("est", renderer = number_renderer) %>%
        hot_col("se", renderer = number_renderer) %>%
        hot_col("ci_l", renderer = number_renderer) %>%
        hot_col("ci_u", renderer = number_renderer) %>%
        hot_col("year", format = "0")
    })

    output$hot_program <- renderRHandsontable({
        rhandsontable(state$program_wide, stretchH = "all") %>%
            hot_col("NbTested", renderer = number_renderer) %>%
            hot_col("NbTestPos", renderer = number_renderer) %>%
            hot_col("NbANCTested", renderer = number_renderer) %>%
            hot_col("NBTestedANCPos", renderer = number_renderer)
    })

    observeEvent(input$surveyData, {
        inFile <- input$surveyData

        if (is.null(inFile)){
            return(NULL)
        }

        state$survey <<- read.csv(inFile$datapath)
    })

    observeEvent(input$programData, {
        inFile <- input$programData

        if (is.null(inFile)){
        return(NULL)
        }

        state$program <<- read.csv(inFile$datapath)
    })

    observe({
        if(!is.null(input$hot_survey)){
            state$survey <<- hot_to_r(input$hot_survey)
        }
    })

    observe({
        if(!is.null(input$hot_program)){
            state$program_wide <- hot_to_r(input$hot_program)
        }
    })

    state
}
