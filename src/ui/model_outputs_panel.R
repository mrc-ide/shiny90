panelModelOutputs <- function() {
    withSpinner <- shinycssloaders::withSpinner

    shiny::div("",
        shiny::div("", class="mb-5 suggest-save",
            shiny::span("Now that the model has been run, you can "),
            shiny::tags$a(href = "", class="shiny-download-link", id="digestDownload2", "download a digest file", target = "_blank", download = NA),
            shiny::span("containing your input data and results. You can re-upload this file later to view your results again and change your input data.")
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
            shiny::tabPanel("Proportion ever tested",
                div("", class="outputs-ever-tested",
                    shiny::dataTableOutput("outputs_table_ever_tested")
                )
            ),
            shiny::tabPanel("Proportion aware",
                div("", class="outputs-aware",
                    shiny::dataTableOutput("outputs_table_aware")
                )
            ),
            shiny::tabPanel("ART coverage",
                div("", class="outputs-art-coverage",
                    shiny::dataTableOutput("outputs_table_art_coverage")
                )
            )
        )
    )
}
