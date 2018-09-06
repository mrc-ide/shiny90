library(shiny)
library(shinyjs)

disableUIOnBusy <- function() {
    div("", class="busy-indicator",
        div("",
            div("",
                p("Please wait..."),
                img(src="images/ajax-loader.gif")
            )
        ),
        includeScript("js/disableUIOnBusy.js")
    )
}

ui <- div(id="shiny90",
    includeCSS("css/style.css"),
    includeCSS("css/bootstrap4.css"),

    useShinyjs(),
    extendShinyjs(text=file.readText("js/nav.js"), functions=c("enableTab", "disableTab")),

    conditionalPanel(
        condition="!output.workingSet_selected",
        welcomeView()
    ),
    conditionalPanel(
        condition="output.workingSet_selected",
        mainView()
    ),
    disableUIOnBusy()
)