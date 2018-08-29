panelModelRun <- function() {
    div("",
        h3("Enter model parameters"),
        inputBox("parameter2", "Z", "Number of iterations", value = "500"),
        inputBox("parameter1", "X", "Sincerity", value = "5"),
        inputBox("parameter3", "A", "Enthusiam", value = "0.23"),
        inputBox("parameter4", "N2", "Proportion that Jeff makes up", value = "8"),
        actionButton("runModel", "Run model"),
        conditionalPanel(
            condition = "output.requestedModelRun",
            withSpinner(plotOutput(outputId="modelRunResults"))
        )
    )
}
