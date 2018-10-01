library(methods)
context("basic")

testthat::test_that("input plots are rendered", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd)
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    waitForVisible(wd$findElement("css", "#spectrumFileList"))
    expectTextEqual("Uploaded PJNZ files", waitForChildElement(section, "h3"))
    expectTextEqual("Malawi_2018_version_8.PJNZ", section$findChildElement("css", "li span"))

    switchTab(wd, "Upload survey data")

    switchTab(wd, "Upload programmatic data")

    switchTab(wd, "Review input data")
    waitForShinyToNotBeBusy(wd)

    expectElementPresent(wd, inActivePane("#reviewPrevalence"))
    expectElementPresent(wd, inActivePane("#reviewIncidence"))
    expectElementPresent(wd, inActivePane("#reviewTotalPop"))
    expectElementPresent(wd, inActivePane("#reviewPLHIV"))
    expectElementPresent(wd, inActivePane("#reviewTotalTests"))
    expectElementPresent(wd, inActivePane("#reviewTotalPositive"))
    expectElementPresent(wd, inActivePane("#reviewTotalANC"))
    expectElementPresent(wd, inActivePane("#reviewTotalANCPositive"))
})