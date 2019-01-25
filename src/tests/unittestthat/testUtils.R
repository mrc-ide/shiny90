library(methods)
context("basic")

testthat::test_that("program data filename is correctly created", {

    spectrumFilesState <<- c()
    spectrumFilesState$countryAndRegionName <<- function() {
        "test country region"
    }

    result <- templateFileName("dh643jhka")
    testthat::expect_equal(result, "dh643jhka-data-testcountryregion.csv")

})

