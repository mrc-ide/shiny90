library(methods)
testthat::context("basic")

testthat::test_that("can edit working set name and notes", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)
    editWorkingSetMetadata(wd, name = "a new name", notes = "multiline\nnotes")
    expectTextEqual("a new name", wd$findElement("css", "#workingSet_name"))
    expectTextEqual("multiline\nnotes", wd$findElement("css", "#workingSet_notes"))
})
