#!/usr/bin/env Rscript

local({r <- getOption("repos")
    r["CRAN"] <- "https://cloud.r-project.org"
    options(repos=r)
})

install.packages("tidyr")
install.packages("numDeriv")
install.packages("shiny")
install.packages("shinyjs")
install.packages("glue")
install.packages("devtools")
install.packages("purrr")
install.packages("rhandsontable")
install.packages("data.table")
install.packages("ggplot2")
install.packages("memoise")

install.packages("httr")
install.packages("RSelenium")
install.packages("testthat")


devtools::install_github('andrewsali/shinycssloaders')
devtools::install_github("mrc-ide/first90release")
