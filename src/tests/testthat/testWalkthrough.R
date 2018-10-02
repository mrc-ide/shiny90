library(methods)
testthat::context("basic")

testthat::test_that("title is present", {
    wd$navigate(appURL)
    expectTextEqual("Shiny 90", wd$findElement(using = "css", ".title"))
})

testthat::test_that("can walk through app", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd)
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)
    expectTextEqual("Uploaded PJNZ files", waitForChildElement(section, "h3"))
    expectTextEqual("Malawi_2018_version_8.PJNZ", section$findChildElement("css", "li span"))

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