ui <- fluidPage(
    includeCSS("css/style.css"),
    includeCSS("css/bootstrap4.css"),
    div(class="row align-items-center mb-3",
        div("Shiny 90", class="header",
            tags$small("", class="pull-right",
                a("About this program and the underlying model", href="#")
            )
        )
    ),
    div(class="row main-content",
        navigation_panel(),
        content_panel()
    ),
    includeScript("js/knockout.js"),
    includeScript("js/ui.js")
)
