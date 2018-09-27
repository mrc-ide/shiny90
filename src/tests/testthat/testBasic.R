library(methods)
context("basic")

driver <- RSelenium::remoteDriver(
    browserName = "phantomjs"
)
driver$open()
appURL <- "http://localhost:8080"

testthat::test_that("can connect to app", {
    driver$navigate(appURL)
    title <- driver$findElement(using = "css selector", ".title")
    expect_equal(title$getElementText()[[1]], "Shiny 90")
})

driver$close()