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

            out <- fitModel(tableData$survey, tableData$program, pjnzFilePath())
            likdat <- out$likdat
            fp <- out$fp

            mod <- eppasm::simmod.specfp(fp)

            survey_dt <- as.data.table(tableData$survey, keep.rownames=TRUE)

            out_evertest = outEverTest(fp, mod)
            out_nbtest = numberTested(fp, mod)
            out_nbtest_pos = numberTestedPositive(fp, mod)
            out_negative = negativeTestData(survey_dt, out_evertest)
            out_positive = positiveTestData(survey_dt, out_evertest)
            out_all = allTestData(survey_dt, out_evertest)

            first_90 = first90Data(fp, mod)

            output$outputs_totalNumberOfTests <- renderPlot({

                yAxisLimits <- c(0, max(likdat$vctanc$tot, na.rm=TRUE)/1000 + max(likdat$vctanc$tot, na.rm=TRUE)/1000*0.2)

                plot(I(likdat$vctanc$tot/1000) ~ likdat$vctanc$year,
                        pch=16,
                        ylim=yAxisLimits,
                        cex=1.5,
                        ylab='Number of tests (in 1000s)',
                        xlab='year',
                        xlim=c(2000, 2017),
                        main='Total number of tests')

                lines(I(out_nbtest$value/1000) ~ out_nbtest$year, lwd=2, col='steelblue4')

            })

            output$outputs_numberOfPositiveTests <- renderPlot({

                yAxisLimits <- c(0, max(likdat$vctanc_pos$tot, na.rm=TRUE)/1000 + +max(likdat$vctanc_pos$tot, na.rm=TRUE)/1000*0.2)

                plot(I(likdat$vctanc_pos$tot/1000) ~ likdat$vctanc_pos$year,
                        pch=16,
                        ylim=yAxisLimits,
                        cex=1.5,
                        ylab='Number of positive tests (in 1000s)',
                        xlab='year', xlim=c(2000, 2017),
                        main='Number of positive tests')

                lines(I(out_nbtest_pos$value/1000) ~ out_nbtest_pos$year, lwd=2, col='violetred4')

            })

            output$outputs_percentageNegativeOfTested <- renderPlot({

                out_f <- out_negative$out_f
                out_m <- out_negative$out_m
                dat_f <- out_negative$dat_f
                dat_m <- out_negative$dat_m

                plot(out_f$value ~ out_f$year, type='l',
                    ylim=c(0,1),
                    col='maroon',
                    main="% negative of all ever tested",
                    xlim=c(2000, 2017),
                    ylab='% negative ever tested',
                    xlab='Year',
                    lwd=2)

                lines(out_m$value ~ out_m$year, col='navy', lwd=2)

                points(dat_f$est ~ dat_f$year, pch=15, col='maroon')
                points(dat_m$est ~ dat_m$year, pch=16, col='navy')

                segments(x0=dat_f$year, y0=dat_f$ci_l, x1=dat_f$year, y1=dat_f$ci_u, lwd=2, col='maroon')
                segments(x0=dat_m$year, y0=dat_m$ci_l, x1=dat_m$year, y1=dat_m$ci_u, lwd=2, col='navy')
            })

            output$outputs_percentagePLHIVOfTested <- renderPlot({

                out_f <- out_positive$out_f
                out_m <- out_positive$out_m
                dat_f <- out_positive$dat_f
                dat_m <- out_positive$dat_m

                plot(out_f$value ~ out_f$year,
                    type='l',
                    ylim=c(0,1),
                    col='maroon',
                    main='% PLHIV of all ever tested',
                    xlim=c(2000, 2017),
                    ylab='% PLHIV of ever tested',
                    xlab='Year',
                    lwd=2)

                lines(out_m$value ~ out_m$year, col='navy', lwd=2)

                points(dat_f$est ~ I(dat_f$year-0.1), pch=15, col='maroon')
                points(dat_m$est ~ I(dat_m$year+0.1), pch=16, col='navy')

                segments(x0=dat_f$year-0.1, y0=dat_f$ci_l, x1=dat_f$year-0.1, y1=dat_f$ci_u, lwd=2, col='maroon')
                segments(x0=dat_m$year+0.1, y0=dat_m$ci_l, x1=dat_m$year+0.1, y1=dat_m$ci_u, lwd=2, col='navy')
            })

            output$outputs_percentageTested <- renderPlot({

                out_f <- out_all$out_f
                out_m <- out_all$out_m
                dat_f <- out_all$dat_f
                dat_m <- out_all$dat_m

                plot(out_f$value ~ out_f$year,
                    type='l',
                    ylim=c(0,1),
                    col='maroon',
                    main='% of population ever tested',
                    xlim=c(2000, 2017),
                    ylab='% ever tested',
                    xlab='Year',
                    lwd=2)

                lines(out_m$value ~ out_m$year, col='navy', lwd=2)

                points(dat_f$est ~ I(dat_f$year+0.1), pch=15, col='maroon')
                points(dat_m$est ~ I(dat_m$year-0.1), pch=16, col='navy')

                segments(x0=dat_f$year+0.1, y0=dat_f$ci_l, x1=dat_f$year+0.1, y1=dat_f$ci_u, lwd=2, col='maroon')
                segments(x0=dat_m$year-0.1, y0=dat_m$ci_l, x1=dat_m$year-0.1, y1=dat_m$ci_u, lwd=2, col='navy')

            })

            output$outputs_firstAndSecond90 <- renderPlot({

                out_a <- first_90$out_a

                out_ever_all <- subset(out_evertest, agegr == '15-49' & outcome == 'evertest' & sex == 'both' & hivstatus == 'positive')

                out_art <- first_90$out_art

                plot(out_a$value ~ out_a$year,
                    type='l',
                    ylim=c(0,1),
                    col='darkslategrey',
                    main='First and second 90',
                    xlim=c(2000, 2017),
                    ylab='%',
                    xlab='Year',
                    lwd=2)

                lines(out_art$value ~ out_art$year, col='deepskyblue2', lwd=2, lty=1)
                lines(out_ever_all$value ~ out_ever_all$year, col='orange3', lwd=2, lty=1)

                legend(x=2000, y=0.95, legend = c('PLHIV Ever Tested','PLHIV Aware','ART Cov'),
                col=c('orange3','darkslategrey','deepskyblue2'), lwd=3, bty='n')
            })
        }
        else{

        }
    })

    outputOptions(output, "requestedModelRun", suspendWhenHidden = FALSE)

}
