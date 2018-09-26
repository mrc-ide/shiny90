#!/usr/bin/env Rscript
url <- "http://localhost:8080"


print(glue::glue("Waiting for shiny app to be available at {url}"))
devnull <- httr::RETRY("GET", url, times = 4, quiet = TRUE)
print("Shiny is available; running tests...")

testthat::test_dir("src/tests/testthat")