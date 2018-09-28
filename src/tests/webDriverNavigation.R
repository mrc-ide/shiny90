switchTab <- function(wd, tabText) {
    selector <- glue::glue("a[data-toggle=tab][data-value='{tabText}']")
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