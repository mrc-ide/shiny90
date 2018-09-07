library(shiny)
library(data.table)
library(rhandsontable)
library(first90)

surveyAndProgramData <- function(input, output, state) {
    data(survey_hts)
    data(prgm_dat)

    state$survey = as.data.frame(survey_hts[country == "Malawi"])

    prgm_dat$country = as.character(prgm_dat$country)
    prgm_dat$notes = as.character(prgm_dat$notes)

    state$program = prgm_dat[prgm_dat$country == "Malawi", ]

    number_renderer = "function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.textAlign = 'right';
        }"

    text_renderer = "function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
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
        rhandsontable(state$program, stretchH = "all") %>%
        hot_col("number", renderer = number_renderer) %>%
        hot_col("country", renderer = text_renderer)
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
            state$program <<- hot_to_r(input$hot_program)
        }
    })

    state
}
