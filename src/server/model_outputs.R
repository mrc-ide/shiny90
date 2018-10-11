fitModel <- function(likelihood, spectrumData) {
    # Starting parameters
    data("theta0", package="first90")

    first90::ll_hts(theta0, spectrumData, likelihood)

    maxIterations <- 250
    if (Sys.getenv("SHINY90_TEST_MODE") == "TRUE") {
        maxIterations <- 2
    }

    optim(theta0, first90::ll_hts, fp = spectrumData, likdat = likelihood, method="BFGS",
                    control=list(fnscale = -1, trace=4, REPORT=1, maxit=maxIterations))
}
