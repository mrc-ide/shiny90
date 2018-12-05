library(methods)
testthat::context("basic")

testthat::test_that("uploading bad spectrum file gives error message", {
    wd$navigate(appURL)

    # Start new working set
    startNewWorkingSet(wd)

    # Upload spectrum file
    fileName <- tempfile()
    f <- file(fileName)
    tryCatch({ writeLines("blah blah", f) }, finally = { close(f) })
    uploadSpectrumFile(wd, dir="", filename = fileName)
    errorBox <- wd$findElement("css", inActivePane("#spectrumFileError"))
    waitForVisible(errorBox)
    expectTextToContain("Unable to read the contents of this file", errorBox)
})

testthat::test_that("can plot pjnz", {
    wd$navigate(appURL)
    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename = "Togo_Centrale_2018.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    expectElementPresent(wd, inActivePane("#spectrumPrevalence"))
    expectElementPresent(wd, inActivePane("#spectrumIncidence"))
    expectElementPresent(wd, inActivePane("#spectrumTotalPop"))
    expectElementPresent(wd, inActivePane("#spectrumPLHIV"))
})

testthat::test_that("can upload multiple spectrum files and then remove one", {
    wd$navigate(appURL)
    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename = "Togo_Centrale_2018.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    uploadSpectrumFile(wd, filename = "Togo_Maritime_2018.PJNZ")
    files <- waitForThisManyChildren(section, "li", 2)
    expectTextEqual("Togo_Centrale_2018.PJNZ", files[[1]]$findChildElement("css", "span"))
    expectTextEqual("Togo_Maritime_2018.PJNZ", files[[2]]$findChildElement("css", "span"))
    files[[1]]$findChildElement("css", "button")$clickElement()
    files <- waitForThisManyChildren(section, "li", 1)
    expectTextEqual("Togo_Maritime_2018.PJNZ", files[[1]]$findChildElement("css", "span"))
})

testthat::test_that("cannot upload spectrum files from different countrues", {
    wd$navigate(appURL)
    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename = "Togo_Centrale_2018.PJNZ")
    waitForVisible(wd$findElement("css", ".uploadedSpectrumFilesSection"))

    uploadSpectrumFile(wd) # default, which is Malawi
    errorBox <- wd$findElement("css", inActivePane("#spectrumFileError"))
    waitForVisible(errorBox)
    expectTextToContain("one country at a time", errorBox)
})

testthat::test_that("warning is shown if multiple regional files are uploaded and working set name is country", {
    wd$navigate(appURL)
    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename = "Togo_Centrale_2018.PJNZ")
    waitForVisible(wd$findElement("css", ".uploadedSpectrumFilesSection"))

    uploadSpectrumFile(wd, filename = "Togo_Maritime_2018.PJNZ")
    warningBox <- wd$findElement("css", inActivePane("#multiple-region-warning"))
    waitForVisible(warningBox)
    expectTextToContain("You have uploaded files for multiple regions", warningBox)
    expectTextEqual("Togo", wd$findElement("css", "#workingSet_name"))
})

testthat::test_that("warning is not shown if single regional file is uploaded and working set name is region", {
    wd$navigate(appURL)
    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename = "Togo_Centrale_2018.PJNZ")
    waitForVisible(wd$findElement("css", ".uploadedSpectrumFilesSection"))

    warningBox <- wd$findElement("css", inActivePane("#multiple-region-warning"))
    testthat::expect_false(isVisible(warningBox))
    expectTextEqual("Centrale", wd$findElement("css", "#workingSet_name"))
})