library(magrittr)

getProgramDataInWideFormat <- function(country) {
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
        wide <- tidyr::spread(long, key = "type", value = "number")
    }

    wide[c("year", "NbTested", "NbTestPos", "NbANCTested", "NBTestedANCPos")]
}

surveyAndProgramData <- function(input, output, state, spectrumFilesState) {
    data("survey_hts", package="first90")
    data("prgm_dat", package="first90")

    shiny::observeEvent(spectrumFilesState$country, {

        if (!is.null(spectrumFilesState$country)){
            state$survey <- as.data.frame(survey_hts)
            state$survey <- state$survey[state$survey$country == spectrumFilesState$country & state$survey$outcome == "evertest", ]
            state$program_wide <- getProgramDataInWideFormat(spectrumFilesState$country)
        }
    })

    state$program <- shiny::reactive({
        tidyr::gather(state$program_wide,
            key = "type", value = "number",
            "NbTested", "NbTestPos", "NbANCTested", "NBTestedANCPos"
        )
    })

    state$anyProgramData <- shiny::reactive({ !is.null(state$program_wide) && nrow(state$program_wide %>% na.omit()) > 0 })

    output$noProgramData <- shiny::reactive({ !state$anyProgramData() })

    shiny::outputOptions(output, "noProgramData", suspendWhenHidden = FALSE)

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

        state$program_wide <<- read.csv(inFile$datapath)
    })

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
            state$program_wide <<- rhandsontable::hot_to_r(input$hot_program)
            state$programTableChanged <<- state$programTableChanged + 1
        }
    })

    state
}
