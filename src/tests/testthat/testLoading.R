library(methods)
testthat::context("basic")

loadDigest <- function(wd, dir, filename, selector) {
    waitFor(function() {
        loadButton <- wd$findElement("css", selector)
        loadButton$clickElement()

        modal <- wd$findElement("css", "#digestModal .modal-dialog")
        isVisible(modal)
    })

    uploadFile(wd, dir, filename, "#digestUpload")
    waitForVisible(wd$findElement("css", "#workingSet_name"))
}

loadDigestFromWelcome <- function(wd, dir="../../../sample_files/", filename = "testing1234.zip.shiny90") {
    loadDigest(wd, dir, filename, "#welcomeRequestDigestUpload")
}

loadDigestFromMainUI <- function(wd, dir="../../../sample_files/", filename = "testing1234.zip.shiny90") {
    loadDigest(wd, dir, filename, "#requestDigestUpload")
}

testthat::test_that("can load digest from welcome page", {
    wd$navigate(appURL)
    loadDigestFromWelcome(wd)
    expectTextEqual("testing1234", wd$findElement("css", "#workingSet_name"))
    verifyPJNZFileUpload("Malawi_2018_version_8.PJNZ")

    switchTab(wd, "Upload survey data")
    waitForVisible(wd$findElement("css", "#hot_survey"))

    switchTab(wd, "Upload programmatic data")
    waitForVisible(wd$findElement("css", "#hot_program"))
})

testthat::test_that("can save digest with top left button", {
    wd$navigate(appURL)

    # Save it
    startNewWorkingSet(wd)
    editWorkingSetMetadata(wd, name = "minimal", notes = "Just name and notes")
    wd$findElement("css", "#digestDownload1")$clickElement()
    waitForDownloadedFile("minimal.zip.shiny90")

    # Load it and check it
    wd$navigate(appURL)
    loadDigestFromWelcome(wd, dir = "../../../selenium_files/", filename = "minimal.zip.shiny90")
    expectTextEqual("minimal", wd$findElement("css", "#workingSet_name"))
    expectTextEqual("Just name and notes", wd$findElement("css", "#workingSet_notes"))
})

testthat::test_that("can save digest from review tab and outputs tab", {
    wd$navigate(appURL)
    loadDigestFromWelcome(wd)

    # Save it from review tab
    editWorkingSetMetadata(wd, name = "from_review")
    switchTab(wd, "Review input data")
    link = wd$findElement("css", inActivePane(".suggest-save a"))
    expectTextEqual("download a digest file", link)

    downloadFileFromLink(link, "from_review.zip.shiny90")

    # Save it from outputs tab
    switchTab(wd, "Run model")
    runModel()

    editWorkingSetMetadata(wd, name = "from_outputs")
    link = wd$findElement("css", inActivePane(".suggest-save a"))
    waitForVisible(link)
    expectTextEqual("download a digest file", link)

    downloadFileFromLink(link, "from_outputs.zip.shiny90")

    # Load each one and check them
    loadDigestFromMainUI(wd, dir = "../../../selenium_files/", filename = "from_review.zip.shiny90")
    expectTextEqual("from_review", wd$findElement("css", "#workingSet_name"))

    switchTab(wd, "Upload spectrum file(s)")
    verifyPJNZFileUpload("Malawi_2018_version_8.PJNZ")

    loadDigestFromMainUI(wd, dir = "../../../selenium_files/", filename = "from_outputs.zip.shiny90")
    expectTextEqual("from_outputs", wd$findElement("css", "#workingSet_name"))

    switchTab(wd, "Upload spectrum file(s)")
    verifyPJNZFileUpload("Malawi_2018_version_8.PJNZ")

    switchTab(wd, "Run model")
    waitFor(function() { isVisible(wd$findElement("css", "#model-outputs")) })

    expectTextToContain("Now that the model has been run", wd$findElement("css", inActivePane(".suggest-save")))
})