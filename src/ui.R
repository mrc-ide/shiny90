disableUIOnBusy <- function() {
    shiny::div("", class = "modal busy-indicator",
        shiny::div("", class = "modal-dialog",
            shiny::div("", class = "modal-content",
                shiny::div("", class = "modal-body",
                    shiny::p("Please wait..."),
                    shiny::img(src = "images/ajax-loader.gif")
                )
            )
        ),
        shiny::includeScript("js/disableUIOnBusy.js")
    )
}

ui <- shiny::div(id = "shiny90",
    shiny::includeCSS("css/style.css"),
    shiny::includeCSS("css/bootstrap4.css"),

    shinyjs::useShinyjs(),
    shinyjs::extendShinyjs(text = file.readText("js/nav.js"), functions = c("enableTab", "disableTab")),

    shiny::includeScript("js/enableEnterButton.js"),

    shiny::conditionalPanel(
        condition = "!output.workingSet_selected",
        welcomeView()
    ),
    shiny::conditionalPanel(
        condition = "output.workingSet_selected",
        mainView()
    ),
    shiny::conditionalPanel(
        condition = "output.modal == 'loadDigest'",
        loadDigestModal()
    ),
    shiny::conditionalPanel(
        condition = "output.modal == 'editWorkingSet'",
        editWorkingSetModal()
    ),
    disableUIOnBusy()
)