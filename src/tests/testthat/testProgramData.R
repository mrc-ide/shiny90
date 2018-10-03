library(methods)
testthat::context("basic")

testthat::test_that("can upload a new set of program data for the same country", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename= "Malawi_2018_version_8.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    switchTab(wd, "Upload programmatic data")
    uploadFile(wd, filename = "fakeprogramdata_malawi.csv", inputId="#programData")

    Sys.sleep(1.5)
    rows <- wd$findElements("css", "#hot_program .ht_master tbody .rowHeader")

    # there are 3 rows in the test program data
    testthat::expect_equal(length(rows), 3)
})

testthat::test_that("cannot upload progam data with wrong headers", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename= "Malawi_2018_version_8.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    switchTab(wd, "Upload programmatic data")
    uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#programData")

    Sys.sleep(1.5)
    rows <- wd$findElements("css", "#hot_program .ht_master tbody .rowHeader")

    # there are more than 3 rows in the original program data, 3 in the test data
    testthat::expect_gt(length(rows), 3)

})

testthat::test_that("cannot upload program data for a different country", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename= "Malawi_2018_version_8.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    switchTab(wd, "Upload programmatic data")
    uploadFile(wd, filename = "fakeprogramdata_angola.csv", inputId="#programData")

    Sys.sleep(1.5)
    rows <- wd$findElements("css", "#hot_program .ht_master tbody .rowHeader")

    # there are more than 3 rows in the original program data, 3 in the test data
    testthat::expect_gt(length(rows), 3)

})