library(methods)
testthat::context("basic")

testthat::test_that("can load digest from welcome page", {
    wd$navigate(appURL)
    loadDigestFromWelcome(wd)

    waitFor(function() {
        getText(wd$findElement("css", "#workingSet_name")) == "Malawi"
    })

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
    editWorkingSetMetadata(wd, "Nothing yet")
    wd$findElement("css", "#digestDownload1")$clickElement()
    waitForDownloadedFile("Unknown.zip.shiny90")

    # Load it and check it
    wd$navigate(appURL)
    loadDigestFromWelcome(wd, dir = "../../../selenium_files/", filename = "Unknown.zip.shiny90")
    expectTextEqual("Unknown", wd$findElement("css", "#workingSet_name"))
    expectTextEqual("Nothing yet", wd$findElement("css", "#workingSet_notes"))
})

testthat::test_that("can save digest from review tab", {
    wd$navigate(appURL)
    loadDigestFromWelcome(wd)

    # Save it from review tab
    editWorkingSetMetadata(wd, "from_review")
    switchTab(wd, "Review input data")
    link = wd$findElement("css", inActivePane(".save-button a"))
    expectTextEqual("Save your work", link)

    downloadFileFromLink(link, "Malawi.zip.shiny90")

    # Load and check
    loadDigestFromMainUI(wd, dir = "../../../selenium_files/", filename = "Malawi.zip.shiny90")
    expectTextEqual("Malawi", wd$findElement("css", "#workingSet_name"))
    expectTextEqual("from_review", wd$findElement("css", "#workingSet_notes"))

    removeFile("Malawi.zip.shiny90")
})

testthat::test_that("can save digest from output tab", {
    wd$navigate(appURL)
    loadDigestFromWelcome(wd)

    # Save it from outputs tab
    switchTab(wd, "Run model")
    runModel()

    editWorkingSetMetadata(wd, "from_outputs")
    link = wd$findElement("css", inActivePane(".save-button a"))
    waitForVisible(link)
    expectTextEqual("Download shiny90 outputs for Spectrum", link)

    downloadFileFromLink(link, "Malawi.zip.shiny90")

    # Load and check
    wd$navigate(appURL)
    loadDigestFromWelcome(wd, dir = "../../../selenium_files/")

    expectedName <- "Malawi"
    nameElement <- wd$findElement("css", "#workingSet_name")
    waitFor(function() {
        getText(nameElement) == expectedName
    })

    expectTextEqual(expectedName, nameElement)
    expectTextEqual("from_outputs", wd$findElement("css", "#workingSet_notes"))

    switchTab(wd, "Run model")
    waitForVisible(wd$findElement("css", "#outputs_totalNumberOfTests"))

    expectElementPresent(wd, inActivePane("#outputs_totalNumberOfTests"))
    expectElementPresent(wd, inActivePane("#outputs_numberOfPositiveTests"))
    expectElementPresent(wd, inActivePane("#outputs_percentageNegativeOfTested"))
    expectElementPresent(wd, inActivePane("#outputs_percentagePLHIVOfTested"))
    expectElementPresent(wd, inActivePane("#outputs_percentageTested"))
    expectElementPresent(wd, inActivePane("#outputs_firstAndSecond90"))
    expectElementPresent(wd, inActivePane("#outputs_womenEverTested"))
    expectElementPresent(wd, inActivePane("#outputs_menEverTested"))

    switchTab(wd, "Advanced outputs")
    expectElementPresent(wd, inActivePane("#outputs_retest_neg"))
    expectElementPresent(wd, inActivePane("#outputs_retest_pos"))
    expectElementPresent(wd, inActivePane("#outputs_prv_pos_yld"))

})

testthat::test_that("can save and load regional data", {
    wd$navigate(appURL)
    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, dir="../../../sample_files/", filename = "Togo_Centrale_2018.PJNZ")
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    downloadPath <- file.path(downloadedFiles, "Togo-Centrale.zip.shiny90")
    wd$findElement("css", "#digestDownload1")$clickElement()
    waitForAndTryAgain(function() { file.exists(downloadPath) }, function() { wd$findElement("css", "#digestDownload1")$clickElement()})

    # Load and check
    wd$navigate(appURL)
    loadDigestFromWelcome(wd, dir = "../../../selenium_files/", filename = "Togo-Centrale.zip.shiny90")

    expectedName <- "Togo - Centrale"
    waitFor(function() {
        getText(wd$findElement("css", "#workingSet_name")) == expectedName
    })

    expectTextEqual(expectedName, wd$findElement("css", "#workingSet_name"))

    switchTab(wd, "Upload survey data")
    switchTab(wd, "Upload programmatic data")
})
