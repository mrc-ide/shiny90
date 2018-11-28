library(methods)
testthat::context("basic")

testthat::test_that("can edit working set name and notes", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    editWorkingSetMetadata(wd, "some notes")

    expectTextEqual("some notes", wd$findElement("css", "#workingSet_notes"))
})

testthat::test_that("country name is displayed in header", {

    wd$navigate(appURL)

    loadDigestFromWelcome(wd)

    waitFor(function() {
        getText(wd$findElement("css", "#workingSet_name")) == "Malawi"
    })
})

testthat::test_that("unknown country is displayed in header", {

    wd$navigate(appURL)

    startNewWorkingSet(wd)

    expectTextEqual("Unknown", wd$findElement("css", "#workingSet_name"))
})
