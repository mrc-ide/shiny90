panelModelOutputs <- function() {
    shiny::div("",
        shiny::div("",
            shiny::span("Now that the model has been run, you can "),
            shiny::tags$a(href = "", id="digestDownload2", "download a digest file", target = "_blank", download = NA),
            shiny::span("containing your input data and results. You can re-upload this file later to view your results again and change your input data.")
        ),
        shiny::div("", class = "row",
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "outputs_totalNumberOfTests"))),
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "outputs_numberOfPositiveTests")))
        ),
        shiny::div("", class = "row",
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "outputs_percentageNegativeOfTested"))),
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "outputs_percentagePLHIVOfTested")))
        ),
        shiny::div("", class = "row",
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "outputs_percentageTested"))),
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "outputs_firstAndSecond90")))
        ),
        shiny::h3("Tabular data"),
        # TODO
        # By year (2000 to current):
        # - Proportion ever tested by status
        # - Proportion aware
        # - ART coverage
        # Download full long format data set (stratified by age and sex)
        shiny::img(src = "images/mock-sheet.png")

        # TODO
        # We want these 6 plots for the full output age range without original data points
        # And we also want these figures:
        # - Cross-sectional estimates
        # - Proportion of HIV+ tests that are new diagnoses
        # - Prevalance, positivity and true yield of new diagnoses
    )
}
