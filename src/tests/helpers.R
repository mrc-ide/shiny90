getText <- function(element) {
    texts <- element$getElementText()
    if (length(texts) > 1) {
        testthat::fail(message = "More than one element matched the expression")
    }
    texts[[1]]
}

enterText <- function(element, text) {
    element$sendKeysToElement(list(text))
}

expectTextEqual <- function(expected, element) {
    testthat::expect_equal(getText(element), expected)
}