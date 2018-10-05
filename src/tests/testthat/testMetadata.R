library(methods)
testthat::context("basic")

testthat::test_that("can edit working set name and notes", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    wd$findElement("css", "a#editWorkingSet")$clickElement()
    enterText(wd$findElement("css", "#editWorkingSet_name"), "a new name", clear = TRUE)
    enterText(wd$findElement("css", "#editWorkingSet_notes"), "multiline\nnotes")
    wd$findElement("css", "#editWorkingSet_update")$clickElement()

    expectTextEqual("a new name", wd$findElement("css", "#workingSet_name"))
    expectTextEqual("multiline\nnotes", wd$findElement("css", "#workingSet_notes"))
})
