panelModelRun <- function() {
    shiny::div("",
        shiny::h3("Enter model fitting parameters"),
        shiny::fluidRow(
            shiny::div("", class = "col-xs-12 col-sm-6",
                inputBox("parameter2", "A", "Explantation for parameter A", value = "500"),
                inputBox("parameter1", "X", "Explantation for parameter B", value = "5")
                # Weight to programmatic data (dropdown? value?)
            )
        ),
        actionButtonWithCustomClass("runModel", "Run model", cssClasses = "btn-red btn-lg btn-success"),
        shiny::div("This make take several minutes. Please do not close your browser.", class = "mt-3"),
        shiny::conditionalPanel(
            condition = "output.modelRunState == 'finished'",
            shiny::div("", class = "mt-3",
                shiny::h2("Model run complete"),
                shiny::div("Click 'View model outputs' in the sidebar to see the outputs")
                # We want the 6 plots currently on the output page, constrained to the age range
                # present in the input data and with the original data points plotted
            )
        ),
        shiny::conditionalPanel(
            condition = "output.modelRunState == 'error'",
            div("", class = "mt-3 alert alert-warning",
            div("Model run failed. Please check your input data.")
            # TODO: link to help email? Explain data needs?
            )
        )
    )
}
