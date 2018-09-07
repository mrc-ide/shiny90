library(shiny)
library(shinycssloaders)

panelModelOutputs <- function() {
    div("",
        div("", class="mb-5",
            span("Now that the model has been run, you can "),
            tags$a(href = "#", "download a digest file"),
            span("containing your input data and results. You can re-upload this file later to view your results again and change your input data.")
        ),
        tabsetPanel(
            tabPanel("Figures",
                fluidRow(
                    div("", class = "col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_totalNumberOfTests"))),
                    div("", class = "col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_numberOfPositiveTests")))
                ),
                fluidRow(
                    div("", class = "col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_percentageNegativeOfTested"))),
                    div("", class = "col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_percentagePLHIVOfTested")))
                ),
                fluidRow(
                    div("", class = "col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_percentageTested"))),
                    div("", class = "col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_firstAndSecond90")))
                )
                # We also want these figures:
                # - TODO: Cross-sectional estimates
                # - TODO: Proportion of HIV+ tests that are new diagnoses
                # - TODO: Prevalance, positivity and true yield of new diagnoses
            ),
            tabPanel("Data",
                # TODO: By year (2000 to current): Proportion ever tested by status, Proportion aware, ART coverage
                # TODO: Download full long format data set (stratified by age and sex)
                div("", class="mt-3",
                    dataTableOutput("outputs_data")
                )
            )
        )
    )
}
