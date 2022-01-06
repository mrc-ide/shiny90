#!/usr/bin/env Rscript
url <- "http://localhost:8080"


print(glue::glue("Waiting for shiny app to be available at {url}"))
devnull <- httr::RETRY("GET", url, times = 4, quiet = TRUE)
print("Shiny is available; running tests...")

source("src/tests/helpers.R")
source("src/tests/logic.R")
source("src/tests/webDriverNavigation.R")

tryCatch({
   testthat::test_dir("src/tests/testthat", stop_on_failure = TRUE, stop_on_warning = TRUE)
  # testthat::test_file("src/tests/testthat/testWalkthrough.R")
}, finally={wd$close()})
