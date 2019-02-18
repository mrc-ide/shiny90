library(methods)
testthat::context("basic")

testthat::test_that("warning is shown if incomplete program data is present", {

    uploadSpectrumFileAndSwitchTab("Upload survey data", filename= "Angola_201805v4.PJNZ")
    uploadFile(wd, filename = "fakesurvey_angola.csv", inputId="#surveyData")

    switchTab(wd, "Review input data")
    warning <- wd$findElement("css", ".mt-5.alert.alert-warning")

    waitForVisible(warning)

    expectTextEqual("The programmatic data for your country is incomplete. Please fill in missing values if you have them.", warning)
})

testthat::test_that("warning is not shown if complete program data is present", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "testprogramdata_malawi.csv", inputId="#programData")
    Sys.sleep(2)

    switchTab(wd, "Upload survey data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

    switchTab(wd, "Review input data")
    warning <- wd$findElement("css", ".mt-5.alert.alert-warning")

    waitFor(function() {
        !isVisible(warning)
    })

    testthat::expect_false(isVisible(warning))
})

testthat::test_that("error is shown if invalid program data is present", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "inconsistent_programdata_malawi.csv", inputId="#programData")
    Sys.sleep(2)

    switchTab(wd, "Upload survey data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

    switchTab(wd, "Review input data")
    error <- wd$findElement("css", ".mt-5.alert.alert-danger")

    waitForVisible(error)

    expectTextEqual("The programmatic data for your country is invalid. Please check the guidance and correct it.", error)
})

testthat::test_that("error is not shown if valid program data is present", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "testprogramdata_malawi.csv", inputId="#programData")
    Sys.sleep(2)

    switchTab(wd, "Upload survey data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

    switchTab(wd, "Review input data")
    error <- wd$findElement("css", ".mt-5.alert.alert-danger")

    waitFor(function() {
        !isVisible(error)
    })

    testthat::expect_false(isVisible(error))
})

testthat::test_that("error is not shown if program data has uppercase sex values", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "testprogramdata_uppercasesex_malawi.csv", inputId="#programData")
    Sys.sleep(2)

    switchTab(wd, "Upload survey data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")

    switchTab(wd, "Review input data")
    error <- wd$findElement("css", ".mt-5.alert.alert-danger")

    waitFor(function() {
        !isVisible(error)
    })

    testthat::expect_false(isVisible(error))
})

testthat::test_that("can upload a new set of program data for the same country", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "testprogramdata_malawi.csv", inputId="#programData")

    Sys.sleep(2)
    rows <- wd$findElements("css", "#hot_program .ht_master tbody tr")

    # there are 3 rows in the test program data
    testthat::expect_equal(length(rows), 3)
})

testthat::test_that("cannot upload progam data with wrong headers", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "badprogramdata_malawi.csv", inputId="#programData")

    Sys.sleep(2)
    rows <- wd$findElements("css", "#hot_program .ht_master tbody tr")

    # there are more than 3 rows in the original program data, 3 in the test data
    testthat::expect_gt(length(rows), 3)

    errorAlert <- wd$findElement("css", "#wrongProgramHeadersError")
    waitForVisible(errorAlert)
    expectTextEqual("Error: Invalid headers! Program data must match the given column headers. This file has been ignored.", errorAlert)

})

testthat::test_that("cannot upload program data for a different country", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")
    uploadFile(wd, filename = "testprogramdata_angola.csv", inputId="#programData")

    Sys.sleep(2)
    rows <- wd$findElements("css", "#hot_program .ht_master tbody tr")

    # there are more than 3 rows in the original program data, 3 in the test data
    testthat::expect_gt(length(rows), 3)

    errorAlert <- wd$findElement("css", "#wrongProgramCountryError")
    waitForVisible(errorAlert)
    expectTextEqual("Error: You cannot upload program data for a different country. This file has been ignored.", errorAlert)
})


testthat::test_that("can download program data template with correct country name", {

    uploadSpectrumFileAndSwitchTab("Upload programmatic data")

    downloadLink <- wd$findElement("css", "#downloadProgramTemplate")
    expectTextEqual("Download CSV template", downloadLink)

    downloadLink$clickElement()
    downloadPath <-file.path(downloadedFiles, "program-data-Malawi.csv")
    waitForAndTryAgain(function() { file.exists(downloadPath) }, function() {
        downloadLink$clickElement()
    })

    uploadNewSpectrumFile(wd)
    switchTab(wd, "Upload programmatic data")

    downloadLink <- wd$findElement("css", "#downloadProgramTemplate")
    expectTextEqual("Download CSV template", downloadLink)

    downloadLink$clickElement()
    downloadPath <-file.path(downloadedFiles, "program-data-Togo-Centrale.csv")
    waitForAndTryAgain(function() { file.exists(downloadPath) }, function() {
        downloadLink$clickElement()
    })

})
