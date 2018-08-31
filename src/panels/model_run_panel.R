panelModelRun <- function() {
    div("",
        h3("Enter model fitting parameters"),
        fluidRow(
            div("", class="col-xs-12 col-sm-6",
                inputBox("parameter2", "Z", "Number of iterations", value = "500"),
                inputBox("parameter1", "X", "Sincerity", value = "5"),
                inputBox("parameter3", "A", "Enthusiam", value = "0.23"),
                inputBox("parameter4", "N2", "Proportion that Jeff makes up", value = "8")
                # Weight to programmatic data (dropdown? value?)
            )
        ),
        actionButtonWithCustomClass("runModel", "Run model", cssClasses="btn-red btn-lg"),
        div("This make take several minutes. Please do not close your browser.", class="mt-3"),
        conditionalPanel(
            condition = "output.requestedModelRun",
            div("", class="mt-3",
                h2("Modelling fitting results"),
                span("Now that the model has been fitted, you can "),
                tags$a(href="#", "download a digest file"),
                span("containing your input data and results. You can re-upload this file later to view your results again and change your input data.")
                # We want the 6 plots currently on the output page, constrained to the age range
                # present in the input data and with the original data points plotted
            )
        )
    )
}
