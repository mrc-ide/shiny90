#!/usr/bin/env Rscript
install.packages("drat")
drat:::add("mrc-ide")
install.packages(c("provisionr", "buildr", "nomad"))

source("scripts/build_library.R")
build_usb("compiled")
