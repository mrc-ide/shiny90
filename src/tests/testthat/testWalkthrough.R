library(methods)
context("basic")

wd <- RSelenium::remoteDriver(
    browserName = "firefox",
    extraCapabilities = list("moz:firefoxOptions" = list(
        args = list('--headless')
    ))
)
wd$open(silent = TRUE)
on.exit({ wd$close() })
appURL <- "http://localhost:8080"

testthat::test_that("title is present", {
    wd$navigate(appURL)
    expectTextEqual("Shiny 90", wd$findElement(using = "css selector", ".title"))
})

testthat::test_that("can walkthrough app", {
    wd$navigate(appURL)

    # Start new working set
    enterText(wd$findElement("id", "workingSetName"), "Selenium working set")
    wd$findElement("id", "startNewWorkingSet")$clickElement()
    expectTextEqual("Selenium working set", wd$findElement("id", "workingSet_name"))

    # Upload PJNZ file
    expectTextEqual("Upload spectrum file(s)", wd$findElement("class", "panelTitle"))
    fileUpload <- wd$findElement("id", "spectrumFile")
    fileUpload$setElementAttribute("style", "display: inline")
    enterText(fileUpload, normalizePath("../../../sample_files/Malawi_2018_version_8.PJNZ"))
    fileUpload$sendKeysToElement(list(key = "enter"))
})