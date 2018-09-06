mainView <- function() {
    div("",
        div("", class="header",
            fluidPage(
                div("", class="pull-right text-right",
                    tags$small("",
                        a("About this program and the underlying model", href="#")
                    )
                ),
                div("",
                    digestButtons(),
                    workingSetSection()
                )
            )
        ),
        fluidPage(class="main-content",
            navigationPanel()
        )
    )
}
