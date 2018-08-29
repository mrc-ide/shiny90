ui <- fluidPage(
    includeCSS("css/style.css"),
    includeCSS("css/bootstrap4.css"),
    div(class="row align-items-center",
        div("", class="header",
            tags$small("", class="pull-right",
                a("About this program and the underlying model", href="#")
            ),
            div("", class="pull-left digest-controls",
                div("", class="row",
                    a("", href="#", class="col-md-6 control",
                        img(id="digest-download", src="images/cloud-download.svg", width=32, height=32),
                        tags$br(),
                        tags$label(`for`="digest-download", "Save")
                    ),
                    a("", href="#", class="col-md-6",
                        img(id="digest-upload", src="images/cloud-upload.svg", width=32, height=32),
                        tags$br(),
                        tags$label(`for`="digest-upload", "Load")
                    )
                )
            ),
            div("Shiny 90", class="title")
        )
    ),
    div(class="row main-content",
        navigationPanel()
    )
)
