library(methods)
context("basic")

testthat::test_that("uploading bad spectrum file gives error message", {
    wd$navigate(appURL)

    # Start new working set
    startNewWorkingSet(wd)

    # Upload spectrum file
    fileName <- tempfile()
    f <- file(fileName)
    tryCatch({ writeLines("blah blah", f) }, finally = { close(f) })
    uploadSpectrumFile(wd, path = fileName)
    errorBox <- wd$findElement("css", inActivePane("#spectrumFileError"))
    waitForVisible(errorBox)
    expectTextToContain("Unable to read the contents of this file", errorBox)
})