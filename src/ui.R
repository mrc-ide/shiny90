ui <- fluidPage(
    includeCSS("css/style.css"),
    includeCSS("css/bootstrap4.css"),
    fluidRow("",
        div("", class="col-md-12", style="padding: 0",
            conditionalPanel(
                condition="!output.workingSetSelected",
                welcomeView()
            ),
            conditionalPanel(
                condition="output.workingSetSelected",
                mainView()
            )
        )
    )
)
