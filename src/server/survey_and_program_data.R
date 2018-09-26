library(magrittr)

getProgramDataInWideFormat <- function(country) {
    long <- prgm_dat[prgm_dat$country == country, ]
    long$country <- NULL
    long$notes <- NULL
    wide <- tidyr::spread(long, key = "type", value = "number")
    wide[c("year", "NbTested", "NbTestPos", "NbANCTested", "NBTestedANCPos")]
}

surveyAndProgramData <- function(input, output, state, spectrumFilesState) {
    data("survey_hts", package="first90")
    data("prgm_dat", package="first90")

    shiny::observeEvent(spectrumFilesState$country, {
        state$survey <- as.data.frame(survey_hts)
        state$survey <- state$survey[state$survey$country == spectrumFilesState$country & state$survey$outcome == "evertest", ]
        state$program_wide <- getProgramDataInWideFormat(spectrumFilesState$country)
    })
    state$program <- shiny::reactive({
        tidyr::gather(state$program_wide,
            key = "type", value = "number",
            "NbTested", "NbTestPos", "NbANCTested", "NBTestedANCPos"
        )
    })

    number_renderer = "function (instance, td, row, col, prop, value, cellProperties) {
            Handsontable.renderers.TextRenderer.apply(this, arguments);
            td.style.textAlign = 'right';
        }"

    output$hot_survey <- rhandsontable::renderRHandsontable({
        rhandsontable::rhandsontable(state$survey, stretchH = "all") %>%
            rhandsontable::hot_col("outcome", allowInvalid = TRUE) %>%
            rhandsontable::hot_col("agegr", allowInvalid = TRUE)  %>%
            rhandsontable::hot_col("est", renderer = number_renderer) %>%
            rhandsontable::hot_col("se", renderer = number_renderer) %>%
            rhandsontable::hot_col("ci_l", renderer = number_renderer) %>%
            rhandsontable::hot_col("ci_u", renderer = number_renderer) %>%
            rhandsontable::hot_col("year", format = "0")
    })

    output$hot_program <- rhandsontable::renderRHandsontable({
        rhandsontable::rhandsontable(state$program_wide, stretchH = "all") %>%
            rhandsontable::hot_col("NbTested", renderer = number_renderer) %>%
            rhandsontable::hot_col("NbTestPos", renderer = number_renderer) %>%
            rhandsontable::hot_col("NbANCTested", renderer = number_renderer) %>%
            rhandsontable::hot_col("NBTestedANCPos", renderer = number_renderer)
    })

    shiny::observeEvent(input$surveyData, {
        inFile <- input$surveyData

        if (is.null(inFile)){
            return(NULL)
        }

        state$survey <<- read.csv(inFile$datapath)
    })

    shiny::observeEvent(input$programData, {
        inFile <- input$programData

        if (is.null(inFile)){
        return(NULL)
        }

        state$program <<- read.csv(inFile$datapath)
    })

    shiny::observe({
        if(!is.null(input$hot_survey)){
            state$survey <<- rhandsontable::hot_to_r(input$hot_survey)
        }
    })

    shiny::observe({
        if(!is.null(input$hot_program)){
            state$program_wide <- rhandsontable::hot_to_r(input$hot_program)
        }
    })

    state
}
