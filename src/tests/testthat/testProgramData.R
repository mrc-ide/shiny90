library(methods)
testthat::context("basic")

testthat::test_that("warning is shown if incomplete program data is present", {

    uploadSpectrumFileAndSwitchTab("Review input data", filename= "Angola_201805v4.PJNZ")

    warning <- wd$findElement("css", ".mt-5.alert.alert-warning")

    waitForVisible(warning)

    expectTextEqual("The programmatic data for your country is incomplete. Please fill in missing values if you have them.", warning)
})

testthat::test_that("warning is not shown if complete program data is present", {

    uploadSpectrumFileAndSwitchTab("Review input data")

    expectElementNotVisible(wd, ".alert-warning")
})

testthat::test_that("can upload a new set of program data for the same country", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "testprogramdata_malawi.csv", inputId="#programData")

    Sys.sleep(2)
    rows <- wd$findElements("css", "#hot_program .ht_master tbody .rowHeader")

    # there are 3 rows in the test program data
    testthat::expect_equal(length(rows), 3)
})

testthat::test_that("cannot upload progam data with wrong headers", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "badprogramdata_malawi.csv", inputId="#programData")

    Sys.sleep(2)
    rows <- wd$findElements("css", "#hot_program .ht_master tbody .rowHeader")

    # there are more than 3 rows in the original program data, 3 in the test data
    testthat::expect_gt(length(rows), 3)

    errorAlert <- wd$findElement("css", "#wrongProgramHeadersError")
    waitForVisible(errorAlert)
    expectTextEqual("Invalid headers! Program data must match the given column headers.", errorAlert)

})

testthat::test_that("cannot upload program data for a different country", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "testprogramdata_angola.csv", inputId="#programData")

    Sys.sleep(2)
    rows <- wd$findElements("css", "#hot_program .ht_master tbody .rowHeader")

    # there are more than 3 rows in the original program data, 3 in the test data
    testthat::expect_gt(length(rows), 3)

    errorAlert <- wd$findElement("css", "#wrongProgramCountryError")
    waitForVisible(errorAlert)
    expectTextEqual("You cannot upload program data for a different country.", errorAlert)
})