panelModelOutputs <- function() {
    div("",
        div("", class="row",
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_totalNumberOfTests"))),
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_numberOfPositiveTests")))
        ),
        div("", class="row",
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_percentageNegativeOfTested"))),
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_percentagePLHIVOfTested")))
        ),
        div("", class="row",
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_percentageTested"))),
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "outputs_firstAndSecond90")))
        ),
        h3("Tabular data"),
        # By year (2000 to current):
        # - Proportion ever tested by status
        # - Proportion aware
        # - ART coverage
        # Download full long format data set (stratified by age and sex)
        img(src="images/mock-sheet.png")

        # We want these 6 plots for the full output age range without original data points
        # And we also want these figures:
        # - Cross-sectional estimates
        # - Proportion of HIV+ tests that are new diagnoses
        # - Prevalance, positivity and true yield of new diagnoses
    )
}
