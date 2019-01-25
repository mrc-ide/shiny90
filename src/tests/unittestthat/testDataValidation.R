library(methods)
context("basic")

testthat::test_that("providing both sex aggregated and disaggregated data for a year is invalid", {

    df = data.frame(c(2004,2004), c("both", "male"))
    df$country = "testcountry"
    colnames(df) <- c("year", "sex", "country")

    result <- validateProgramData(df, "testcountry")

    testthat::expect_false(result)
})

testthat::test_that("sex disaggregated data for a year is valid", {

    df = data.frame(c(2010,2010), c("female", "male"))
    df$country = "testcountry"
    colnames(df) <- c("year", "sex", "country")

    result <- validateProgramData(df, "testcountry")

    testthat::expect_true(result)
})

testthat::test_that("sex aggregated data for a year is valid", {

    df = data.frame(c(2010), c("both"))
    df$country = "testcountry"
    colnames(df) <- c("year", "sex", "country")

    result <- validateProgramData(df, "testcountry")

    testthat::expect_true(result)
})

testthat::test_that("missing gender is invalid if sex disaggregated", {

    df = data.frame(c(2010), c("male"))
    df$country = "testcountry"
    colnames(df) <- c("year", "sex", "country")

    result <- validateProgramData(df, "testcountry")

    testthat::expect_false(result)
})

testthat::test_that("duplicated sex is invalid", {

    df = data.frame(c(2010, 2010), c("male", "male"))
    df$country = "testcountry"
    colnames(df) <- c("year", "sex", "country")

    result <- validateProgramData(df, "testcountry")

    testthat::expect_false(result)

    df = data.frame(c(2010, 2010), c("both", "both"))
    colnames(df) <- c("year", "sex")

    result <- validateProgramData(df, "testcountry")

    testthat::expect_false(result)
})

testthat::test_that("providing both sex aggregated and disaggregated data for multiple years is valid", {

    df = data.frame(c(2010, 2011, 2011), c("both", "male", "female"))
    df$country = "testcountry"
    colnames(df) <- c("year", "sex", "country")

    result <- validateProgramData(df, "testcountry")

    testthat::expect_true(result)
})

testthat::test_that("wrong country in program data is invalid", {

    df = data.frame(c(2010), c("both"))
    df$country = "testcountry"
    colnames(df) <- c("year", "sex", "country")

    result <- validateProgramData(df, "someothercountry")

    testthat::expect_false(result)
})

testthat::test_that("wrong country in survey data is invalid", {
    df = data.frame(c(2010, 2011, 2011), c("both", "male", "female"))
    df$country = "testcountry"
    colnames(df) <- c("year", "sex", "country")
    
    result <- validateSurveyData(df, "other country")
    
    testthat::expect_false(result)
})

testthat::test_that("All same country is valid", {
  df = data.frame(c(2010, 2011, 2011), c("both", "male", "female"))
  df$country = "testcountry"
  colnames(df) <- c("year", "sex", "country")
  
  result <- validateSurveyData(df, "testcountry")
  
  testthat::expect_true(result)
})
