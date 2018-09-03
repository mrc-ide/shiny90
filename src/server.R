library(shiny)
library(purrr)
library(glue)
library(data.table)
library(first90)
library(rhandsontable)
library(ggplot2)

server <- function(input, output) {

    options(shiny.maxRequestSize=30*1024^2)

    # ---- Working set ----
    workingSet <- reactiveVal(
        list(name=NULL, notes=NULL)
    )
    output$workingSetSelected <- reactive({ !is.null(workingSet()$name) })
    output$workingSet_name <- reactive({ workingSet()$name })
    output$workingSet_notes <- reactive({ workingSet()$notes })
    output$workingSet_new_error <- reactive({NULL})
    observeEvent(input$startNewWorkingSet, {
        if (input$workingSetName != "") {
            workingSet(list(name=input$workingSetName, notes="Cupcake ipsum dolor sit amet. Dessert gummies tootsie roll croissant pudding. Marzipan cookie jujubes cotton candy lollipop. Dessert ice cream soufflé.

Marzipan jelly beans candy canes biscuit. Chocolate cake tart jelly beans marzipan cookie toffee gingerbread carrot cake gummi bears. Chocolate pastry dessert apple pie liquorice biscuit ice cream pastry macaroon."))
            output$workingSet_new_error <- reactive({NULL})
        } else {
            output$workingSet_new_error <- reactive({"A name is required"})
        }
    })
    outputOptions(output, "workingSet_new_error", suspendWhenHidden = FALSE)
    outputOptions(output, "workingSetSelected", suspendWhenHidden = FALSE)

    # ---- Upload spectrum files ----
    pjnzFilePath <- reactiveVal("")
    spectrumFiles <- reactiveVal(character())
    observeEvent(input$spectrumFile, {
        inFile <- input$spectrumFile
        if (!is.null(inFile)) {
            pjnzFilePath(inFile$datapath)
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

    # ---- surveyData and programData ----
    data(survey_hts)
    data(prgm_dat)

    tableData = reactiveValues()

    tableData$survey = as.data.frame(survey_hts[country == "Malawi"])

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

    # ---- renderModelRunResults ----
    output$requestedModelRun <- reactive({FALSE})

    observeEvent(input$runModel, {

        output$requestedModelRun <- reactive({TRUE})

        if (nchar(pjnzFilePath()) > 0){

            # the model fitting code expects survey data as a data table and program data as a data frame
            # it could presumably be re-written to deal with survey data as a data frame but for now we're just
            # converting survey data to the expected format
            survey_dt <- as.data.table(tableData$survey, keep.rownames=TRUE)

            out <- fitModel(survey_dt, tableData$program, pjnzFilePath())

            # model fit results
            likdat <- out$likdat
            fp <- out$fp
            mod <- eppasm::simmod.specfp(fp)

            # model output
            out_evertest = outEverTest(fp, mod)

            output$outputs_totalNumberOfTests <- renderPlot({
                plotTotalNumberOfTests(fp, mod, likdat)
            })

            output$outputs_numberOfPositiveTests <- renderPlot({
                plotNumberOfPositiveTests(fp, mod, likdat)
            })

            output$outputs_percentageNegativeOfTested <- renderPlot({
                plotPercentageNegativeOfTested(survey_dt, out_evertest)
            })

            output$outputs_percentagePLHIVOfTested <- renderPlot({
                plotPercentagePLHIVOfTested(survey_dt, out_evertest)
            })

            output$outputs_percentageTested <- renderPlot({
                plotPercentageTested(survey_dt, out_evertest)
            })

            output$outputs_firstAndSecond90 <- renderPlot({
               plotFirstAndSecond90(fp, mod, out_evertest)
            })
        }
        else{

        }
    })

    outputOptions(output, "requestedModelRun", suspendWhenHidden = FALSE)

}
