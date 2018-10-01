appURL <- "http://localhost:8080"
wd <- RSelenium::remoteDriver(
    browserName = "firefox",
    extraCapabilities = list("moz:firefoxOptions" = list(
        args = list('--headless')
    ))
)
wd$open(silent = TRUE)

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

expectTextToContain <- function(expectedText, element) {
    actualText <- getText(element)
    expect(
        ok = grepl(expectedText, actualText, fixed=TRUE),
        failure_message = glue::glue("Expected to find string '{expectedText}' in '{actualText}'")
    )
}

expectElementPresent <- function(wd, cssSelector) {
    elements <- wd$findElements("css", cssSelector)
    testthat::expect(
        ok = length(elements) > 0,
        failure_message = glue::glue("Expected an element in the page to match {cssSelector}")
    )
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

isBusy <- function(wd) {
    script <- 'return $("html").hasClass("shiny-busy")'
    wd$executeScript(script)[[1]]
}

waitForShinyToNotBeBusy <- function(wd, timeout = 10) {
    waitFor(function() { !isBusy(wd) }, timeout = timeout)
}