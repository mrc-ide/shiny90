panelModelRun <- function() {
    div("",
        h3("Enter model fitting parameters"),
        inputBox("parameter2", "Z", "Number of iterations", value = "500"),
        inputBox("parameter1", "X", "Sincerity", value = "5"),
        inputBox("parameter3", "A", "Enthusiam", value = "0.23"),
        inputBox("parameter4", "N2", "Proportion that Jeff makes up", value = "8"),
        actionButton("runModel", "Run model"),
        div("This make take several minutes. Please do not close your browser.", class="mt-3"),
        conditionalPanel(
            condition = "output.requestedModelRun",
            div("", class="mt-3",
                h2("Modelling fitting results"),
                span("Now that the model has been fitted, you can "),
                tags$a(href="#", "download a digest file"),
                span("containing your input data and results. You can re-upload this file later to view your results again and change your input data."),
                withSpinner(plotOutput(outputId="modelFittingResults")),
                h3("Tabular data"),
                img(src="images/mock-sheet.png")
            )
        )
    )
}
