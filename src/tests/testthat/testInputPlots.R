library(methods)
context("basic")
testthat::test_that("input plots are rendered", {

    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFileAndSwitchTab("Upload survey data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

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