switchTab <- function(wd, tabText, timeout=5) {
    selector <- glue::glue("a[data-toggle=tab][data-value='{tabText}']")

    link <- wd$findElement("css", selector)
    waitFor(function(){
        link$getElementAttribute("class") != "disabled"
    }, timeout)

    waitFor(function() {
        link <- wd$findElement("css", selector)
        link$clickElement()
        title <- wd$findElement("css", inActivePane(".panelTitle"))
        tabText == getText(title)
    })
}

inActivePane <- function(cssSelector) {
    glue::glue(".tab-pane.active {cssSelector}")
}