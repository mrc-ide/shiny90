library(methods)
context("basic")

testthat::test_that("providing both sex aggregated and disaggregated data for a year is invalid", {

    df = data.frame(c(2010,2010), c("both", "male"))
    colnames(df) <- c("year", "sex")

    result <- validateProgramData(df)

    testthat::expect_false(result)
})

testthat::test_that("sex disaggregated data for a year is valid", {

    df = data.frame(c(2010,2010), c("female", "male"))
    colnames(df) <- c("year", "sex")

    result <- validateProgramData(df)

    testthat::expect_true(result)
})

testthat::test_that("sex aggregated data for a year is valid", {

    df = data.frame(c(2010), c("both"))
    colnames(df) <- c("year", "sex")

    result <- validateProgramData(df)

    testthat::expect_true(result)
})

testthat::test_that("missing gender is invalid if sex disaggregated", {

    df = data.frame(c(2010), c("male"))
    colnames(df) <- c("year", "sex")

    result <- validateProgramData(df)

    testthat::expect_false(result)
})

testthat::test_that("duplicated sex is invalid", {

    df = data.frame(c(2010, 2010), c("male", "male"))
    colnames(df) <- c("year", "sex")

    result <- validateProgramData(df)

    testthat::expect_false(result)

    df = data.frame(c(2010, 2010), c("both", "both"))
    colnames(df) <- c("year", "sex")

    result <- validateProgramData(df)

    testthat::expect_false(result)
})
