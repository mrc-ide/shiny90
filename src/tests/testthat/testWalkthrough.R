library(methods)
context("basic")

wd <- RSelenium::remoteDriver(
    browserName = "firefox"
    # extraCapabilities = list("moz:firefoxOptions" = list(
    #     args = list('--headless')
    # ))
)
wd$open(silent = TRUE)
on.exit({ wd$close() })
appURL <- "http://localhost:8080"

getText <- function(element) {
    texts <- element$getElementText()
    if (length(texts) > 1) {
        testthat::fail(message = "More than one element matched the expression")
    }
    texts[[1]]
}

expectTextEqual <- function(expected, element) {
    expect_equal(getText(element), expected)
}

testthat::test_that("title is present", {
    wd$navigate(appURL)
    expectTextEqual("Shiny 90", wd$findElement(using = "css selector", ".title"))
})

testthat::test_that("can walkthrough app", {
    wd$navigate(appURL)
    wd$findElement("id", "workingSetName")$sendKeysToElement(list("Selenium working set"))
    wd$findElement("id", "startNewWorkingSet")$clickElement()
    expectTextEqual("Selenium working set", wd$findElement("id", "workingSet_name"))
    expectTextEqual("Upload spectrum file(s)", wd$findElement("class", "panelTitle"))
})