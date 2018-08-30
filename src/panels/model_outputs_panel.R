panelModelOutputs <- function() {
    div("",
        plotOutput(outputId="modelRunResults"),
        h3("Tabular data"),
        img(src="images/mock-sheet.png")
    )
}
