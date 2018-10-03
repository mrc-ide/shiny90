switchTab <- function(wd, tabText) {
    selector <- glue::glue("a[data-toggle=tab][data-value='{tabText}']")
    link <- wd$findElement("css", selector)

    waitFor(function(){
        link$getElementAttribute("class") != "disabled"
    })

    waitFor(function() {
        link$clickElement()
        title <- wd$findElement("css", inActivePane(".panelTitle"))
        tabText == getText(title)
    })
}

inActivePane <- function(cssSelector) {
    glue::glue(".tab-pane.active {cssSelector}")
}