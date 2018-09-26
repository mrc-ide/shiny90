mainView <- function() {
    shiny::div("",
        shiny::div("", class = "header",
            shiny::fluidPage(
                shiny::div("", class = "pull-right text-right",
                    shiny::tags$small("",
                        shiny::a("About this program and the underlying model", href = "#")
                    )
                ),
                shiny::div("",
                    digestButtons(),
                    workingSetSection()
                )
            )
        ),
        shiny::fluidPage(class = "main-content",
            navigationPanel()
        )
    )
}
