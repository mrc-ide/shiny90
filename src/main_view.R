mainView <- function() {
    div("",
        div("", class="header",
            fluidRow(
                div("", class="col-md-6 col-sm-12",
                    div("", class="info",
                        div("",
                            tags$strong("Current working set:"),
                            textOutput("workingSet_name", inline=TRUE)
                        ),
                        div("",
                            tags$strong("Working set notes:"),
                            textOutput("workingSet_notes", inline=TRUE)
                        )
                    ),
                    a("", href="#", class="digest-button",
                        img(id="digest-download", src="images/cloud-download.svg", width=32, height=32),
                        tags$br(),
                        tags$label(`for`="digest-download", "Save")
                    ),
                    a("", href="#", class="digest-button",
                        img(id="digest-upload", src="images/cloud-upload.svg", width=32, height=32),
                        tags$br(),
                        tags$label(`for`="digest-upload", "Load")
                    )
                ),
                div("", class="col-md-6 col-sm-12 text-right",
                    tags$small("",
                        a("About this program and the underlying model", href="#")
                    )
                )
            )
        ),
        div("", class="main-content",
            navigationPanel()
        )
    )
}
