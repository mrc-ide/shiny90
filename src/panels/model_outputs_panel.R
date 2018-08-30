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
        img(src="images/mock-sheet.png")
    )
}
