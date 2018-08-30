panelModelFit <- function() {
    div("",
        actionButton("startModelFitting", "Begin model fitting"),
        div("This make take several minutes. Please do not close your browser.", class="mt-3"),
        conditionalPanel(
            condition = "output.requestedModelFitting",
            div("", class="mt-3",
                h2("Modelling fitting results"),
                span("Now that the model has been fitted, you can "),
                tags$a(href="#", "download a digest file"),
                span("containing your input data and model fitting results. You can re-upload this file later to continue working with the same input data."),
                withSpinner(plotOutput(outputId="modelFittingResults"))
            )
        )
    )
}
