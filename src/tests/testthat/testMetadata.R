library(methods)
testthat::context("basic")

testthat::test_that("can edit working set name and notes", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    waitFor(function(){

        editWorkingSetMetadata(wd, name = "a new name", notes = "multiline\nnotes")
        getText(wd$findElement("css", "#workingSet_name")) == "a new name"
    })

    expectTextEqual("multiline\nnotes", wd$findElement("css", "#workingSet_notes"))
})
