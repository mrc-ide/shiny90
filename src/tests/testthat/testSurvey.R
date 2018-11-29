library(methods)
testthat::context("basic")

testthat::test_that("can upload a new set of survey data for the same country", {

    uploadSpectrumFileAndSwitchTab("Upload survey data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

    Sys.sleep(2)
    rows <- wd$findElements("css", "#hot_survey .ht_master tbody tr")

    # there are 4 rows in the test survey data
    testthat::expect_equal(length(rows), 4)
})

testthat::test_that("cannot upload a csv with wrong headers", {

    uploadSpectrumFileAndSwitchTab("Upload survey data")

    uploadFile(wd, filename = "badsurvey_malawi.csv", inputId="#surveyData")

    Sys.sleep(2)
    rows <- wd$findElements("css", "#hot_survey .ht_master tbody tr")

    # there are more than 4 rows in the original survey data, 4 in the test data
    testthat::expect_gt(length(rows), 4)

    errorAlert <- wd$findElement("css", "#wrongSurveyHeadersError")
    expectTextEqual("Error: Invalid headers! Survey data must match the given column headers. This file has been ignored.", errorAlert)
})

testthat::test_that("cannot upload a csv for a different country", {

    uploadSpectrumFileAndSwitchTab("Upload survey data")

    uploadFile(wd, filename = "fakesurvey_angola.csv", inputId="#surveyData")

    Sys.sleep(2)
    rows <- wd$findElements("css", "#hot_survey .ht_master tbody tr")

    # there are more than 4 rows in the original survey data, 4 in the test data
    testthat::expect_gt(length(rows), 4)

    errorAlert <- wd$findElement("css", "#wrongSurveyCountryError")
    expectTextEqual("Error: You cannot upload survey data for a different country. This file has been ignored.", errorAlert)
})


testthat::test_that("can reset to built in data", {

    uploadSpectrumFileAndSwitchTab("Upload survey data")

    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

    # there are more than 4 rows in the original survey data, 4 in the test data
    waitFor(function() {

        wd$findElement("css", "#resetSurveyData")$clickElement()
        rows <- wd$findElements("css", "#hot_survey .ht_master tbody tr")
        length(rows) == 4
    })

    waitFor(function() {

        wd$findElement("css", "#resetSurveyData")$clickElement()
        rows <- wd$findElements("css", "#hot_survey .ht_master tbody tr")
        length(rows) > 4
    })

    testthat::expect_gt(length(rows), 4)
})