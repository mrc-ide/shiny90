ui <- div(
    includeCSS("css/style.css"),
    includeCSS("css/bootstrap4.css"),
    conditionalPanel(
        condition="!output.workingSetSelected",
        welcomeView()
    ),
    conditionalPanel(
        condition="output.workingSetSelected",
        mainView()
    )
)
