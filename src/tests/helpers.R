dir.create("selenium_files", showWarnings = FALSE)
downloadedFiles <- normalizePath("selenium_files", mustWork = TRUE)

dir.create("selenium_screenshots", showWarnings = FALSE)
screenshotsFolder <- normalizePath("selenium_screenshots", mustWork = TRUE)

appURL <- "http://localhost:8080"
profile <- RSelenium::makeFirefoxProfile(list(
    # This is an enum, '2' means use the value in the next parameter
    "browser.download.dir" = downloadedFiles,
    "browser.download.folderList" = 2L,
    "browser.helperApps.neverAsk.saveToDisk" = "application/zip"
))
wd <- RSelenium::remoteDriver(
    browserName = "firefox",
    extraCapabilities = c(
        list("moz:firefoxOptions" = list(
            args = list('--headless')
        )),
        profile
    )
)
wd$open(silent = TRUE)
print(glue::glue("Downloads will be saved to {downloadedFiles}"))

getText <- function(element) {
    texts <- element$getElementText()
    if (length(texts) > 1) {
        testthat::fail(message = "More than one element matched the expression")
    }
    texts[[1]]
}

enterText <- function(element, text, clear = FALSE) {
    if (clear) {
        element$clearElement()
    }
    element$sendKeysToElement(list(text))
    Sys.sleep(0.5)
}

expectTextEqual <- function(expected, element) {
    testthat::expect_equal(getText(element), expected)
}

expectTextToContain <- function(expectedText, element) {
    actualText <- getText(element)
    testthat::expect(
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

numberScreenshot <- local({
    counter <- 0
    function(){
        counter <<- counter + 1
        counter
    }
})

waitFor <- function(predicate, timeout = 5) {
    waited <- 0
    while (!predicate()) {
        Sys.sleep(0.25)
        waited <- waited + 0.25
        if (waited >= timeout) {
            num <- numberScreenshot()
            screenshotPath <- file.path(screenshotsFolder, glue::glue('test{num}.png'))
            wd$screenshot(file = screenshotPath)
            stop(glue::glue("Timed out waiting {timeout}s for predicate to be true - screenshot {screenshotPath}"))
        }
    }
}

waitForElement <- function(wd, cssSelector) {
    elements <- waitForThisManyElements(wd, cssSelector, 1)
    elements[[1]]
}

waitForThisManyElements <- function(wd, cssSelector, expectedNumber) {
    waitFor(function() {
        length(wd$findElements("css", cssSelector)) == expectedNumber
    })
    wd$findElements("css", cssSelector)
}

waitForChildElement <- function(parent, cssSelector) {
    children <- waitForThisManyChildren(parent, cssSelector, 1)
    children[[1]]
}

waitForThisManyChildren <- function(parent, cssSelector, expectedNumber) {
    waitFor(function() {
        length(parent$findChildElements("css", cssSelector)) == expectedNumber
    })
    parent$findChildElements("css", cssSelector)
}

isBusy <- function(wd) {
    script <- 'return $("html").hasClass("shiny-busy")'
    wd$executeScript(script)[[1]]
}

waitForShinyToNotBeBusy <- function(wd, timeout = 10) {
    waitFor(function() { !isBusy(wd) }, timeout = timeout)
}