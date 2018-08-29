panelModelFit <- function() {
    div("",
        actionButton("startModelFitting", "Begin model fitting"),
        div("This make take several minutes. Please do not close your browser.", class="mt-3"),
        textOutput("requestedModelFitting"),
        conditionalPanel(
            condition = "output.requestedModelFitting",
            withSpinner(plotOutput(outputId="modelFittingResults"))
        )
    )
}
