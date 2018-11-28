panelModelRun <- function() {
    shiny::div("",
        actionButtonWithCustomClass("runModel", "Run model", cssClasses = "btn-red btn-lg btn-success"),
        shiny::div("This may take several minutes. Please do not close your browser.", class = "mt-3"
        ),
        shiny::div("", class="mt-3",
            shiny::a("Advanced options", id="showAdvancedOptions", href="#", class="action-button light",
                    shiny::icon("cog", lib = "glyphicon")),
            shiny::conditionalPanel(
                condition = "output.showAdvancedOptions",
                shiny::fluidRow(
                    shiny::div("", class = "col-sm-5 col-xs-12",
                        shiny::div("", class="well mt-3 form form-horizontal",
                            shiny::div("", class = "form-group",
                                shiny::tags$label(`for`="maxIterations", "Maximum iterations", class="control-label col-xs-4"),
                                shiny::div("", class="col-xs-8",
                                    shiny::tags$input(id = "maxIterations", type = "number", value = "250", class = "form-control shiny-bound-input")
                                )
                            ),
                            shiny::div("", class = "form-group",
                                shiny::tags$label(`for`="numSimul", "Number of simulations",  class="control-label col-xs-4"),
                                shiny::div("", class="col-xs-8",
                                    shiny::tags$input(id = "numSimul", type = "number", value = "3000", class = "form-control shiny-bound-input")
                                )
                            )
                        )
                    )
                )
            )
        ),
        shiny::conditionalPanel(
            condition = "output.modelRunState == 'converged'",
            shiny::div("", class = "mt-3",
                shiny::h3("Model run complete")
            )
        ),
        shiny::conditionalPanel(
            condition = "output.modelRunState == 'error'",
            shiny::div("", class = "mt-3 alert alert-warning",
            shiny::div("Model run failed. Please check your input data.")
            # TODO: link to help email? Explain data needs?
            )
        ),
        panelModelOutputs()
    )
}
