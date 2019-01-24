panelModelOutputs <- function() {
    withSpinner <- shinycssloaders::withSpinner

    shiny::div("",
        shiny::conditionalPanel(
            condition = "output.modelRunState == 'converged'",
            shiny::div("", id="model-outputs",
                shiny::div("", class="mb-3 suggest-save",
                    shiny::span("Now that the model has been run, you can download the shiny90 outputs for importing 
                                into Spectrum. This will download a file containing your input data and results. You can 
                                also re-upload this file later to view your results again and change your input data.")
                ),
                shiny::div("", class="mb-5 save-button",
                    downloadButtonWithCustomClass("digestDownload2", "Download shiny90 outputs for Spectrum")
                ),
                shiny::tabsetPanel(
                    shiny::tabPanel("Figures",
                        shiny::div("", class = "row",
                            shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_totalNumberOfTests"))),
                            shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_numberOfPositiveTests")))
                        ),
                        shiny::div("", class = "row",
                            shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_percentageNegativeOfTested"))),
                            shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_percentagePLHIVOfTested")))
                        ),
                        shiny::div("", class = "row",
                            shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_percentageTested"))),
                            shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_firstAndSecond90")))
                        ),
                        shiny::div("", class = "row",
                            shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_womenEverTested"))),
                            shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_menEverTested")))
                        )
                    ),
                    shiny::tabPanel("Knowledge of status (%)",
                        div("", class="output-table outputs-aware",
                            select_options("aware",includeStatus = FALSE),
                            shiny::dataTableOutput("outputs_table_aware")
                        )
                    ),
                    shiny::tabPanel("Knowledge of status (absolute)",
                        div("", class="output-table outputs-nbaware",
                            select_options("nbaware",includeStatus = FALSE),
                            shiny::dataTableOutput("outputs_table_nbaware")
                        )
                    ),
                    shiny::tabPanel("Proportion ever tested",
                        div("", class="output-table outputs-ever-tested",
                            select_options("ever_test"),
                            shiny::dataTableOutput("outputs_table_ever_tested")
                        )
                    ),
                    shiny::tabPanel("ART coverage",
                        div("", class="output-table outputs-art-coverage",
                            select_options("art_coverage", includeStatus = FALSE, includeAge = FALSE),
                            shiny::dataTableOutput("outputs_table_art_coverage")
                        )
                    )
                )
            )
        )
    )
}

select_options <- function(id, includeStatus = TRUE, includeAge = TRUE) {

    if (includeStatus){
        status <- shiny::selectizeInput(
                        paste0(id, '_status'),'HIV Status', choices = c("positive", 'negative','all'),
                        multiple = TRUE,
                        selected = "positive")
    }
    else{
        status <- NULL
    }
    if (includeAge){
        age <- shiny::selectizeInput(
                        paste0(id, '_agegr'), 'Age group', choices = c("15-24", '25-34','35-49', '15-49', "15+"),
                        multiple = TRUE,
                        selected = "15+")
    }
    else{
        age <- NULL
    }
    list(shiny::selectizeInput(
            paste0(id, '_sex'), 'Sex', choices = c("both", "male", "female"),
            multiple = TRUE,
            selected = "both"
        ),
        age,
        status
    )
}
