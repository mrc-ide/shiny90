panelModelRun <- function() {
    shiny::div("",
        actionButtonWithCustomClass("runModel", "Run model", cssClasses = "btn-red btn-lg btn-success"),
        shiny::div("This may take several minutes. Please do not close your browser.", class = "mt-3"
        ),
        shiny::div("", class="mt-3",
            shiny::a("Advanced options", id="showAdvancedOptions", href="#", class="action-button light",
                shiny::img(src = "images/gear.svg", width = 20, height = 20)),
            shiny::conditionalPanel(
                condition = "output.showAdvancedOptions",
                shiny::fluidRow(
                    shiny::div("", class = "col-sm-3 col-xs-12",
                        shiny::div("", class = "mt-3 form-group",
                            shiny::tags$label(`for`="maxIterations", "Maximum iterations"),
                                shiny::tags$input(id = "maxIterations", type = "number", value = "250", class = "form-control shiny-bound-input")

                        )
                        # shiny::div("", class = "mt-3 form-group",
                        #     shiny::tags$label(`for`="numSimul", "Number of simmulations"),
                        #         shiny::tags$input(id = "numSimul", type = "number", value = "400", class = "form-control shiny-bound-input")
                        # )
                    )
                )
            )
        ),
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
            shiny::div("", class = "mt-3 alert alert-warning",
            shiny::div("Model run failed. Please check your input data.")
            # TODO: link to help email? Explain data needs?
            )
        )
    )
}
