library(methods)
context("basic")

testthat::test_that("mapHeadersToHumanReadable maps headers", {

    headers <- list(a = "A", b = "B", c = "C")

    n = c(2, 3, 5)
    s = c("aa", "bb", "cc")
    b = c(TRUE, FALSE, TRUE)

    df = data.frame(n,s,b)
    colnames(df) <- c("a", "b", "c")

    result <- mapHeadersToHumanReadable(df, headers)

    testthat::expect_equal(colnames(result), c("A", "B", "C"))
})

testthat::test_that("mapHeadersFromHumanReadable maps headers", {

    headers <- list(a = "A", b = "B", c = "C")

    n = c(2, 3, 5)
    s = c("aa", "bb", "cc")
    b = c(TRUE, FALSE, TRUE)

    df = data.frame(n,s,b)
    colnames(df) <- c("A", "B", "C")

    result <- mapHeadersFromHumanReadable(df, headers)

    testthat::expect_equal(colnames(result), c("a", "b", "c"))
})

testthat::test_that("cast to numeric casts given headers", {

    headers <- list(n = "N", s = "S")

    b = c(TRUE, TRUE, FALSE)
    n = c("2", "3", "5")
    s = c("NA", "NA", "6.3216")

    df = data.frame(b, n, s)
    colnames(df) <- c("b", "n", "s")

    result <- castToNumeric(df, headers)

    testthat::expect_false(is.numeric(result$b))
    testthat::expect_true(is.numeric(result$n))
    testthat::expect_true(is.numeric(result$s))
    testthat::expect_equal(result$s[1], as.numeric(NA))
    testthat::expect_equal(result$s[3], 6.3216)
})

testthat::test_that("anySurveyData is false if not all rows have a survey id", {

    df <- createEmptySurveyData("Malawi")
    result <- anySurveyData(df)

    testthat::expect_false(result)
})

testthat::test_that("anySurveyData is false if no rows", {

    df <- data.frame(surveyid=character())

    result <- anySurveyData(df)

    testthat::expect_false(result)
})

testthat::test_that("anySurveyData is true if one row with surveyid", {

    df <- data.frame(surveyid=c("someid"))

    result <- anySurveyData(df)

    testthat::expect_true(result)
})
