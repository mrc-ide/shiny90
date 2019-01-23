library(methods)
testthat::context("basic")

testthat::test_that("title is present", {
    wd$navigate(appURL)
    expectTextEqual("Shiny 90", wd$findElement(using = "css", ".title"))
})

testthat::test_that("can walk through app", {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd)
    verifyPJNZFileUpload("Malawi_2018_version_8.PJNZ")

    switchTab(wd, "Upload survey data")

    switchTab(wd, "Upload programmatic data")

    switchTab(wd, "Review input data")

    switchTab(wd, "Run model")
    runModel()

    expectElementPresent(wd, inActivePane("#outputs_totalNumberOfTests"))
    expectElementPresent(wd, inActivePane("#outputs_numberOfPositiveTests"))
    expectElementPresent(wd, inActivePane("#outputs_percentageNegativeOfTested"))
    expectElementPresent(wd, inActivePane("#outputs_percentagePLHIVOfTested"))
    expectElementPresent(wd, inActivePane("#outputs_percentageTested"))
    expectElementPresent(wd, inActivePane("#outputs_firstAndSecond90"))
    expectElementPresent(wd, inActivePane("#outputs_womenEverTested"))
    expectElementPresent(wd, inActivePane("#outputs_menEverTested"))

    # Check data tabs
    checkTopLeftTableCellHasThisValue(tabName = "Proportion ever tested",
        tableSelector = ".outputs-ever-tested",
        expectedValue = "2010")
    checkTopLeftTableCellHasThisValue(tabName = "Knowledge of status (%)",
        tableSelector = ".outputs-aware",
        expectedValue = "2010")
    checkTopLeftTableCellHasThisValue(tabName = "Knowledge of status (absolute)",
    tableSelector = ".outputs-nbaware",
    expectedValue = "2010")
    checkTopLeftTableCellHasThisValue(tabName = "ART coverage",
        tableSelector = ".outputs-art-coverage",
        expectedValue = "2010")

    switchTab(wd, "Advanced outputs")
    expectElementPresent(wd, inActivePane("#outputs_retest_neg"))
    expectElementPresent(wd, inActivePane("#outputs_retest_pos"))
    expectElementPresent(wd, inActivePane("#outputs_prv_pos_yld"))

    checkTopLeftTableCellHasThisValue(tabName = "Estimated parameters",
        tableSelector = ".outputs-parameters",
    expectedValue = "RR testing: men in 2005")

    checkTopLeftTableCellHasThisValue(tabName = "Pregnant women",
        tableSelector = ".outputs-preg",
    expectedValue = "2010")
})
