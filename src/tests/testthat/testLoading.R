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
    link = wd$findElement("css", inActivePane(".suggest-save a"))
    expectTextEqual("download a digest file", link)

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
    link = wd$findElement("css", inActivePane(".suggest-save a"))
    waitForVisible(link)
    expectTextEqual("download a digest file", link)

    downloadFileFromLink(link, "Malawi.zip.shiny90")

    # Load and check
    wd$navigate(appURL)
    loadDigestFromWelcome(wd, dir = "../../../selenium_files/")
    expectTextEqual("Malawi", wd$findElement("css", "#workingSet_name"))
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