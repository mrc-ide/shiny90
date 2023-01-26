#!/usr/bin/env Rscript

local({r <- getOption("repos")
    r["CRAN"] <- "https://cloud.r-project.org"
    options(repos=r)
})

install.packages("tidyr")
install.packages("numDeriv")
install.packages("shinyjs")
install.packages("glue")
install.packages("devtools")
install.packages("purrr")
install.packages("rhandsontable")
install.packages("data.table")
install.packages("ggplot2")
install.packages("memoise")
install.packages("writexl")
install.packages("zip")

install.packages('shinycssloaders')
devtools::install_github("mrc-ide/first90release@v1.6.5")
devtools::install_github("rstudio/shiny")
