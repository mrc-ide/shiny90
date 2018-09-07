library(tidyr)
library(shiny)
library(data.table)
library(rhandsontable)
library(first90)

getProgramDataInWideFormat <- function(country) {
    data(prgm_dat)
    program <- prgm_dat[prgm_dat$country == country, ]
    program$country <- NULL
    program$notes <- NULL
    program <- spread(program, key = "type", value = "number")
    program[c("year", "NbTested", "NbTestPos", "NbANCTested", "NBTestedANCPos")]
}

surveyAndProgramData <- function(input, output, state) {
    data(survey_hts)
    data(prgm_dat)

    state$survey <- as.data.frame(survey_hts[country == "Malawi" & outcome == "evertest"])
    state$program_wide <- getProgramDataInWideFormat("Malawi")
    state$program <- reactive({
        gather(state$program_wide,
            key = "type", value = "number",
            "NbTested", "NbTestPos", "NbANCTested", "NBTestedANCPos"
        )
    })

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
