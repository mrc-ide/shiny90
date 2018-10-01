library(methods)
testthat::context("basic")

testthat::test_that("can load digest from welcome page", {
    wd$navigate(appURL)

    loadButton <- wd$findElement("css", "#welcomeRequestDigestUpload")
    loadButton$clickElement()

    modal <- wd$findElement("css", ".modal-dialog")
    waitForVisible(modal)

    uploadDigestFile(wd)

    panelTitle <- wd$findElement("css", inActivePane(".panelTitle"))
    waitForVisible(panelTitle)
    expectTextEqual("Upload spectrum file(s)", panelTitle)

})
