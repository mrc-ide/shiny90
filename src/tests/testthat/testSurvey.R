library(methods)
testthat::context("basic")

uploadSpectrumFileAndSwitchTab <- function(){
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename= "Malawi_2018_version_8.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    switchTab(wd, "Upload survey data")
}

testthat::test_that("can upload a new set of survey data for the same country", {

    uploadSpectrumFileAndSwitchTab()
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

    Sys.sleep(1)
    rows <- wd$findElements("css", "#hot_survey .ht_master tbody .rowHeader")

    # there are 4 rows in the test survey data
    testthat::expect_equal(length(rows), 4)
})

testthat::test_that("cannot upload a csv with wrong headers", {

    uploadSpectrumFileAndSwitchTab()

    uploadFile(wd, filename = "badsurvey_malawi.csv", inputId="#surveyData")

    Sys.sleep(1)
    rows <- wd$findElements("css", "#hot_survey .ht_master tbody .rowHeader")

    # there are more than 4 rows in the original survey data, 4 in the test data
    testthat::expect_gt(length(rows), 4)

    errorAlert <- wd$findElement("css", "#wrongSurveyHeadersError")
    expectTextEqual("Invalid headers! Survey data must match the given column headers.", errorAlert)
})

testthat::test_that("cannot upload a csv for a different country", {

    uploadSpectrumFileAndSwitchTab()

    uploadFile(wd, filename = "fakesurvey_angola.csv", inputId="#surveyData")

    Sys.sleep(1)
    rows <- wd$findElements("css", "#hot_survey .ht_master tbody .rowHeader")

    # there are more than 4 rows in the original survey data, 4 in the test data
    testthat::expect_gt(length(rows), 4)

    errorAlert <- wd$findElement("css", "#wrongSurveyCountryError")
    expectTextEqual("You cannot upload survey data for a different country.", errorAlert)
})