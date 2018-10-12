fitModel <- function(likelihood, spectrumData) {
    # Starting parameters
    data("theta0", package="first90")

    first90::ll_hts(theta0, spectrumData, likelihood)

    testMode <- Sys.getenv("SHINY90_TEST_MODE") == "TRUE"
    maxIterations <- 250
    if (testMode) {
        maxIterations <- 2
    }

    optim(
        theta0,
        first90::ll_hts,
        fp = spectrumData,
        likdat = likelihood,
        method = "BFGS",
        control = list(fnscale = -1, trace=4, REPORT=1, maxit=maxIterations),
        hessian = !testMode
    )
}

runSimulations <- function(opt, spectrumData) {
    testMode <- Sys.getenv("SHINY90_TEST_MODE") == "TRUE"
    if (testMode) {
        NULL
    } else {
        simul.test(opt, spectrumData)
    }
}