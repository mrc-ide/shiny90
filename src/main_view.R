mainView <- function() {
    div("",
        div("", class="header",
            fluidPage(
                fluidRow(
                    div("", class="col-md-6 col-sm-12 info",
                        div("",
                            tags$strong("Current working set:"),
                            textOutput("workingSet_name", inline=TRUE)
                        ),
                        div("",
                            tags$strong("Working set notes:"),
                            textOutput("workingSet_notes", inline=TRUE)
                        )
                    ),
                    div("", class="col-md-6 col-sm-12 text-right",
                        tags$small("",
                            a("About this program and the underlying model", href="#")
                        )
                    )
                )
            )
        ),
        fluidPage(class="main-content",
            navigationPanel()
        )
    )
}
