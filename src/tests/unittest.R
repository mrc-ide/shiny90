#!/usr/bin/env Rscript
library(R.utils)
sourceDirectory("src/server")

testthat::test_dir("src/tests/unittestthat", stop_on_failure = TRUE, stop_on_warning = TRUE)
