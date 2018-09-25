mainView <- function() {
    div("",
        div("", class = "header",
            shiny::fluidPage(
                div("", class = "pull-right text-right",
                    shiny::tags$small("",
                        a("About this program and the underlying model", href = "#")
                    )
                ),
                div("",
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
