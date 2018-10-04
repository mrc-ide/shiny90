library(methods)
context("basic")
testthat::test_that("input plots are rendered", {

    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd)

    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)
    waitForVisible(wd$findElement("css", "#spectrumFileList"))

    switchTab(wd, "Review input data", timeout=10)

    waitForShinyToNotBeBusy(wd)

    expectElementPresent(wd, inActivePane("#reviewTotalTests"))
    expectElementPresent(wd, inActivePane("#reviewTotalPositive"))
    expectElementPresent(wd, inActivePane("#reviewTotalANC"))
    expectElementPresent(wd, inActivePane("#reviewTotalANCPositive"))
    expectElementPresent(wd, inActivePane("#reviewPrevalence"))
    expectElementPresent(wd, inActivePane("#reviewIncidence"))
    expectElementPresent(wd, inActivePane("#reviewTotalPop"))
    expectElementPresent(wd, inActivePane("#reviewPLHIV"))
})