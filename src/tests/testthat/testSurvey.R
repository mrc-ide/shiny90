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

    Sys.sleep(1)
    rows <- wd$findElements("css", "#hot_survey .ht_master tbody .rowHeader")

    testthat::expect_equal(length(rows), 4)
})

testthat::test_that("cannot upload a csv with wrong headers", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename= "Malawi_2018_version_8.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    switchTab(wd, "Upload survey data")
    uploadFile(wd, filename = "badsurvey_malawi.csv", inputId="#surveyData")

    Sys.sleep(1)
    rows <- wd$findElements("css", "#hot_survey .ht_master tbody .rowHeader")

    # 445 is the number of rows in the built in survey data for Malawi
    testthat::expect_equal(length(rows), 445)

    errorAlert <- wd$findElement("css", "#wrongSurveyHeadersError")
    expectTextEqual("Invalid headers! Survey data must match the given column headers.", errorAlert)
})

testthat::test_that("cannot upload a csv for a different country", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename= "Malawi_2018_version_8.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    switchTab(wd, "Upload survey data")
    uploadFile(wd, filename = "fakesurvey_angola.csv", inputId="#surveyData")

    Sys.sleep(1)
    rows <- wd$findElements("css", "#hot_survey .ht_master tbody .rowHeader")

    # 445 is the number of rows in the built in survey data for Malawi
    testthat::expect_equal(length(rows), 445)

    errorAlert <- wd$findElement("css", "#wrongSurveyCountryError")
    expectTextEqual("You cannot upload survey data for a different country.", errorAlert)
})