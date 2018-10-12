getTabLink <- function(wd, tabText) {
    selector <- glue::glue("a[data-toggle=tab][data-value='{tabText}']")
    link <- wd$findElement("css", selector)
}

switchTab <- function(wd, tabText, timeout=10) {
    link <- getTabLink(wd, tabText)
    waitFor(function(){
        link$getElementAttribute("class") != "disabled"
    }, timeout)

    waitFor(function() {
        getTabLink(wd, tabText)$clickElement()
        title <- wd$findElement("css", inActivePane(".panelTitle"))
        tabText == getText(title)
    })
}

isTabEnabled <- function(wd, tabText) {
    getTabLink(wd, tabText)$getElementAttribute("class") != "disabled"
}

inActivePane <- function(cssSelector) {
    glue::glue(".tab-pane.active {cssSelector}")
}