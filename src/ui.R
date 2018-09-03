ui <- div(
    includeCSS("css/style.css"),
    includeCSS("css/bootstrap4.css"),
    conditionalPanel(
        condition="!output.workingSet_selected",
        welcomeView()
    ),
    conditionalPanel(
        condition="output.workingSet_selected",
        mainView()
    )
)
