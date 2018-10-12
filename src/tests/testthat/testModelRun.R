library(methods)
testthat::context("basic")

testthat::test_that("changing survey data invalidates model run", {
    uploadSpectrumFileAndSwitchTab("Run model")
    runModel()
    testthat::expect_true(isTabEnabled(wd, "View model outputs"))

    switchTab(wd, "Upload survey data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")
    waitFor(function() {
        !isTabEnabled(wd, "View model outputs")
    })
})