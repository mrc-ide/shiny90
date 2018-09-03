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
                    div("", style="width: 64px; display: inline-block",
                        a("", href="#", class="digest-button btn-sq btn-sq-sm btn btn-red btn-default text-center",
                            img(id="digest-download", src="images/cloud-download-red.svg", width=32, height=32),
                            tags$br(),
                            tags$label(`for`="digest-download", "Save")
                        ),
                        a("", href="#", class="digest-button btn-sq btn-sq-sm btn btn-red btn-default text-center",
                            img(id="digest-upload", src="images/cloud-upload-red.svg", width=32, height=32),
                            tags$br(),
                            tags$label(`for`="digest-upload", "Load")
                        )
                    ),
                    div("", class="working-set",
                        div("",
                            tags$strong("Current working set:"),
                            span("",
                                textOutput("workingSet_name", inline=TRUE)
                            ),
                            div("", class="pull-right",
                                edit_link()
                            )
                        ),
                        div("",
                            tags$strong("Working set notes:"),
                            textOutput("workingSet_notes", inline=TRUE)
                        ),
                        div("", style="position: absolute; bottom: 0; left: 0; right: 0; height: 50px;
                        background: linear-gradient(to bottom, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 1) 100%);")
                    )
                )
            )
        ),
        fluidPage(class="main-content",
            navigationPanel()
        )
    )
}
