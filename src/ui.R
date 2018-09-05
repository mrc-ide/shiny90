library(shinysky)

load_file <- function(fileName) {
    readChar(fileName, file.info(fileName)$size)
}

ui <- div(
    includeCSS("css/style.css"),
    includeCSS("css/bootstrap4.css"),

    useShinyjs(),
    extendShinyjs(text=load_file("js/nav.js"), functions=c("enableTab", "disableTab")),

    conditionalPanel(
        condition="!output.workingSet_selected",
        welcomeView()
    ),
    conditionalPanel(
        condition="output.workingSet_selected",
        mainView()
    ),

    busyIndicator(wait = 1000)
)
