library(methods)
testthat::context("basic")

testthat::test_that("can upload a new set of survey data for the same country", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename= "Malawi_2018_version_8.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    switchTab(wd, "Upload survey data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

    Sys.sleep(0.5)
    tableBody <- wd$findElement("css", ".htCore")
    rows <- tableBody$findElement("css", "tr")

    testthat::expect_equal(length(rows), 4)
})