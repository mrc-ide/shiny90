context("basic")

driver <- RSelenium::remoteDriver()
driver$open(silent = TRUE)
appURL <- "http://localhost:8080"

testthat::test_that("can connect to app", {
    driver$navigate(appURL)
    title <- driver$findElement(using = "css selector", ".title")
    expect_equal(title$getText(), "Shiny Test App")
})

driver$close()