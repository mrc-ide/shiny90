library(methods)
context("basic")

wd <- RSelenium::remoteDriver(
    browserName = "firefox"
# ,
#     extraCapabilities = list("moz:firefoxOptions" = list(
#         args = list('--headless')
#     ))
)
wd$open(silent = TRUE)
on.exit({ wd$close() })
appURL <- "http://localhost:8080"

uploadSpectrumFile <- function(wd, fileName = "Malawi_2018_version_8.PJNZ") {
    expectTextEqual("Upload spectrum file(s)", wd$findElement("css", inActivePane(".panelTitle")))
    fileUpload <- wd$findElement("css", "#spectrumFile")
    fileUpload$setElementAttribute("style", "display: inline")
    enterText(fileUpload, normalizePath(glue::glue("../../../sample_files/{fileName}")))
    fileUpload$sendKeysToElement(list(key = "enter"))

    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)
}

testthat::test_that("title is present", {
    wd$navigate(appURL)
    expectTextEqual("Shiny 90", wd$findElement(using = "css", ".title"))
})

testthat::test_that("can walk through app", {
    wd$navigate(appURL)

    # Start new working set
    enterText(wd$findElement("css", "#workingSetName"), "Selenium working set")
    wd$findElement("css", "#startNewWorkingSet")$clickElement()
    expectTextEqual("Selenium working set", wd$findElement("css", "#workingSet_name"))

    # Upload spectrum file
    uploadSpectrumFile(wd)
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    expectTextEqual("Uploaded PJNZ files", waitForChildElement(section, "h3"))
    expectTextEqual("Malawi_2018_version_8.PJNZ", waitForChildElement(section, "li span"))

    switchTab(wd, "Upload survey data")

    switchTab(wd, "Upload programmatic data")

    switchTab(wd, "Review input data")

    switchTab(wd, "Run model")
    runModelButton <- wd$findElement("css", inActivePane("#runModel"))
    runModelButton$clickElement()
    waitForShinyToNotBeBusy(wd)

    switchTab(wd, "View model outputs")
    expectElementPresent(wd, inActivePane("#outputs_totalNumberOfTests"))
    expectElementPresent(wd, inActivePane("#outputs_numberOfPositiveTests"))
    expectElementPresent(wd, inActivePane("#outputs_percentageNegativeOfTested"))
    expectElementPresent(wd, inActivePane("#outputs_percentagePLHIVOfTested"))
    expectElementPresent(wd, inActivePane("#outputs_percentageTested"))
    expectElementPresent(wd, inActivePane("#outputs_firstAndSecond90"))
})