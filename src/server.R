library(shiny)
library(purrr)
library(glue)
library(data.table)
library(first90)
library(rhandsontable)

server <- function(input, output) {
    # ---- Working set ----
    workingSet <- reactiveVal(
        list(name=NULL, notes=NULL)
    )
    output$workingSetSelected <- reactive({ !is.null(workingSet()$name) })
    output$workingSet_name <- reactive({ workingSet()$name })
    output$workingSet_notes <- reactive({ workingSet()$notes })
    observeEvent(input$startNewWorkingSet, { workingSet(list(name=input$workingSetName, notes="")) })
    outputOptions(output, "workingSetSelected", suspendWhenHidden = FALSE)

    # ---- Upload spectrum files ----
    spectrumFiles <- reactiveVal(character())
    observeEvent(input$spectrumFile, {
        inFile <- input$spectrumFile
        if (!is.null(inFile)) {
            filename <- inFile$name
            output[[glue("spectrumReview_{filename}")]] <- renderPlot({
                plot(faithful$waiting)
                title(main="Prevalence trend")
            })
            spectrumFiles(c(spectrumFiles(), filename))
        }
    })
    output$anySpectrumFiles <- reactive({length(spectrumFiles()) > 0})
    output$spectrumFileTabs <- renderUI({
        tabs = map(spectrumFiles(), function(filename) {
            tabPanel(filename, plotOutput(glue("spectrumReview_{filename}")))
        })
        do.call(tabsetPanel, tabs)
    })
    outputOptions(output, "anySpectrumFiles", suspendWhenHidden = FALSE)

    # ---- Render input review figures
    output$inputReview_a <- renderPlot({
        plot(faithful$waiting)
        title(main="Figure A")
    })
    output$inputReview_b <- renderPlot({
        plot(faithful$waiting)
        title(main="Figure B")
    })

    # ---- renderModelRunResults ----
    output$requestedModelRun <- reactive({FALSE})
    observeEvent(input$runModel, {
        output$requestedModelRun <- reactive({TRUE})
        output$modelFittingResults <- renderPlot({
            plot(faithful$waiting)
        })
        output$outputs_totalNumberOfTests <- renderPlot({
            plot(faithful$waiting)
            title(main="Total number of tests")
        })
        output$outputs_numberOfPositiveTests <- renderPlot({
            plot(faithful$waiting)
            title(main="Number of positive tests (in 1000s)")
        })
        output$outputs_percentageNegativeOfTested <- renderPlot({
            plot(faithful$waiting)
            title(main="% negative of all ever tested")
        })
        output$outputs_percentagePLHIVOfTested <- renderPlot({
            plot(faithful$waiting)
            title(main="% PLHIV of all ever tested")
        })
        output$outputs_percentageTested <- renderPlot({
            plot(faithful$waiting)
            title(main="% of population ever tested")
        })
        output$outputs_firstAndSecond90 <- renderPlot({
            plot(faithful$waiting)
            title(main="First and second 90s")
        })
    })
    outputOptions(output, "requestedModelRun", suspendWhenHidden = FALSE)

    # ---- surveyData and programData ----
    data(survey_hts)
    data(prgm_dat)

    tableData = reactiveValues()

    tableData$survey = as.data.frame(survey_hts[country == "Malawi" &
        hivstatus == "all" &
        agegr == "15-49" &
        sex == "both" &
        outcome == "evertest"])

    prgm_dat$country = as.character(prgm_dat$country)
    prgm_dat$notes = as.character(prgm_dat$notes)

    tableData$program = prgm_dat[prgm_dat$country == "Malawi", ]

    number_renderer = "function (instance, td, row, col, prop, value, cellProperties) {
        Handsontable.renderers.TextRenderer.apply(this, arguments);
        td.style.textAlign = 'right';
    }"

    text_renderer = "function (instance, td, row, col, prop, value, cellProperties) {
        Handsontable.renderers.TextRenderer.apply(this, arguments);
    }"

    output$hot_survey <- renderRHandsontable({
        rhandsontable(tableData$survey, stretchH = "all") %>%
            hot_col("outcome", allowInvalid = TRUE) %>%
            hot_col("agegr", allowInvalid = TRUE)  %>%
            hot_col("est", renderer=number_renderer) %>%
            hot_col("se", renderer=number_renderer) %>%
            hot_col("ci_l", renderer=number_renderer) %>%
            hot_col("ci_u", renderer=number_renderer) %>%
            hot_col("year", format="0")
    })

    output$hot_program <- renderRHandsontable({
        rhandsontable(tableData$program, stretchH = "all") %>%
            hot_col("number", renderer=number_renderer) %>%
            hot_col("country", renderer=text_renderer)
    })

    observeEvent(input$surveyData, {
        inFile <- input$surveyData

        if (is.null(inFile)){
            return(NULL)
        }

        tableData$survey <<- read.csv(inFile$datapath)
    })

    observeEvent(input$programData, {
        inFile <- input$programData

        if (is.null(inFile)){
            return(NULL)
        }

        tableData$program <<- read.csv(inFile$datapath)
    })

    observe({
        if(!is.null(input$hot_survey)){
            tableData$survey <<- hot_to_r(input$hot_survey)
        }
    })

    observe({
        if(!is.null(input$hot_program)){
            tableData$program <<- hot_to_r(input$hot_program)
        }
    })
}
