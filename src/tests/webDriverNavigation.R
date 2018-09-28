switchTab <- function(wd, tabText) {
    selector <- glue::glue("a[data-toggle=tab][data-value='{tabText}']")
    link <- wd$findElement("css", selector)
    link$clickElement()

    waitFor(function() {
        title <- findInActivePane(wd, ".panelTitle")
        tabText == getText(title)
    })
}

findInActivePane <- function(wd, cssSelector) {
    wd$findElement("css", glue::glue(".tab-pane.active {cssSelector}"))
}

waitForElementInActivePane <- function(wd, cssSelector) {
    waitFor(function() {
        length(wd$findElements("css", glue::glue(".tab-pane.active {cssSelector}"))) > 0
    })
    findInActivePane(wd, cssSelector)
}