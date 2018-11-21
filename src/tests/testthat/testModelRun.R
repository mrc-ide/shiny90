library(methods)
testthat::context("basic")

testthat::test_that("changing survey data invalidates model run", {
    uploadSpectrumFileAndSwitchTab("Run model")
    runModel()

    testthat::expect_true(isVisible(wd$findElement("css", "#model-outputs")))

    switchTab(wd, "Upload survey data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

    waitFor(function() { !isVisible(wd$findElement("css", "#model-outputs")) })
})