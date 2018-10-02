library(methods)
testthat::context("basic")

testthat::test_that("can load digest from welcome page", {
    wd$navigate(appURL)

    loadButton <- wd$findElement("css", "#welcomeRequestDigestUpload")
    loadButton$clickElement()

    modal <- wd$findElement("css", ".modal-dialog")
    waitForVisible(modal)

    uploadDigestFile(wd)

    waitForShinyToNotBeBusy(wd)

    Sys.sleep(0.5)
    expectTextEqual("testing1234", wd$findElement("css", "#workingSet_name"))

})
