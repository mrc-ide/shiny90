getText <- function(element) {
    texts <- element$getElementText()
    if (length(texts) > 1) {
        testthat::fail(message = "More than one element matched the expression")
    }
    texts[[1]]
}

enterText <- function(element, text) {
    element$sendKeysToElement(list(text))
}

expectTextEqual <- function(expected, element) {
    testthat::expect_equal(getText(element), expected)
}

waitForVisible <- function(element) {
    waitFor(function() { element$isElementDisplayed() == "TRUE" })
}

waitFor <- function(predicate, timeout = 5) {
    waited <- 0
    while (!predicate()) {
        Sys.sleep(0.25)
        waited <- waited + 0.25
        if (waited >= timeout) {
            stop("Timed out waiting for predicate to be true")
        }
    }
}

waitForChildElement <- function(parent, cssSelector) {
    waitFor(function() {
        length(parent$findChildElements("css", cssSelector)) > 0
    })
    parent$findChildElement("css", cssSelector)
}

waitForShinyToNotBeBusy <- function(wd, timeout = 10) {
    waitFor(function() {
        wd$executeScript('$("html").hasClass("shiny-busy").length == 0')
    }, timeout = timeout)
}