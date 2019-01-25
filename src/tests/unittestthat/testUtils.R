library(methods)
context("basic")

testthat::test_that("template filenames is correctly created", {

    fakeState <- c()
    fakeState$countryAndRegionName <- function() {
        "test country region"
    }

    result <- templateFileName("dh643jhka", fakeState)
    testthat::expect_equal(result, "dh643jhka-data-testcountryregion.csv")

})

