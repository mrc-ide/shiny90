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

testthat::test_that("program data headers are correct", {

    actualHeaders <- c(names(sharedHeaders),names(programDataHeaders))
    expectedHeaders <- c("country", "year", "sex", "tot", "totpos", "vct", "vctpos", "anc", "ancpos")
    testthat::expect_true(identical(actualHeaders, expectedHeaders))
})


testthat::test_that("can create empty program data with expected headers", {

    df <- createEmptyProgramData("Malawi")

    expectedHeaders <- c(names(sharedHeaders),names(programDataHeaders))
    testthat::expect_true(identical(colnames(df), expectedHeaders))

    testthat::expect_true(all(df$country == "Malawi"))
    testthat::expect_true(all(is.na(df$anc)))
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

testthat::test_that("import program data converts numeric rows to numeric", {

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

createTestProgramData <- function() {
    data.frame("Country or region" = "Malawi",
                Year = c(2010,2011,2011),
                Sex = c('Both', 'Female', "male"),
                "Total Tests" = c("200", "100", "100"),
                "Total Positive Tests" = NA,
                "Total HTC Tests" = NA,
                "Total Positive HTC Tests" = NA,
                "Total ANC Tests" = NA,
                "Total Positive ANC Tests" = NA,
                check.names=FALSE,
                stringsAsFactors = FALSE)
}

testthat::test_that("import program data converts sex to lowercase", {

    testData <- createTestProgramData()
    result <- importProgramData(testData)

    testthat::expect_equal(result$sex[1], "both")
    testthat::expect_equal(result$sex[2], "female")
    testthat::expect_equal(result$sex[3], "male")
})

testthat::test_that("import program data maps headers", {

    testData <- createTestProgramData()
    result <- importProgramData(testData)

    expectedHeaders <- c("country", "year", "sex", "tot", "totpos", "vct", "vctpos", "anc", "ancpos")
    testthat::expect_true(identical(colnames(result), expectedHeaders))
})

testthat::test_that("import program data converts numeric columns", {

    testData <- createTestProgramData()
    result <- importProgramData(testData)

    testthat::expect_true(is.numeric(result$tot))
    testthat::expect_true(is.numeric(result$totpos))
    testthat::expect_true(is.numeric(result$vct))
    testthat::expect_true(is.numeric(result$vctpos))
    testthat::expect_true(is.numeric(result$anc))
    testthat::expect_true(is.numeric(result$ancpos))

    testthat::expect_equal(result$tot[1], 200)
    testthat::expect_equal(result$tot[2], 100)
    testthat::expect_equal(result$tot[3], 100)
})
