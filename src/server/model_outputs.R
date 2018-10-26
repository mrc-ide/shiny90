fitModel <- function(maxIterations, likelihood, spectrumData) {
    # Starting parameters
    data("theta0", package="first90")

    testMode <- Sys.getenv("SHINY90_TEST_MODE") == "TRUE"

    if (testMode) {
        maxIterations <- 2
    }

    opt <- NULL

    shiny::withProgress(message = 'Fitting model', value = 0, {

        i <- Counter$new(par = 0, iteration = 0)

        opt <- optim(
            theta0,
            iterate,
            fp = spectrumData,
            likdat = likelihood,
            maxRuns = maxIterations*2*length(theta0), # this is a heuristic for how many times the model is run by optim
            i = i,
            method = "BFGS",
            control = list(fnscale = -1, trace=4, REPORT=1, maxit=maxIterations)
        )

    })

    opt
}

iterate <- function(theta, fp, likdat, maxRuns, i){

    val <- first90::ll_hts(theta, fp, likdat)

    if (isGradientStep(theta, i$par) || is.nan(val)){
        shiny::incProgress((1/(maxRuns)))
    }
    else {
        shiny::incProgress((1/(maxRuns)), detail= paste("Converging: ", round(val, 2)))
    }

    i$par <- theta
    i$iteration <- i$iteration + 1
    val
}

isGradientStep <- function(theta1, theta2){
    length(which(theta1 != theta2)) < 2
}

iterateHessian <- function(theta, fp, likdat, i){

    shiny::incProgress(1/7300) # 7300 is an approximation of how many times the model will be run to calculate the hessian
    i$iteration <- i$iteration + 1

    first90::ll_hts(theta, fp, likdat)
}

make_progress <- function(n) {
    counter <- 0L
    function() {
        counter <<- counter + 1L
        shiny::incProgress(1/n, detail = glue::glue("Running simulation {counter} of {n}"))
    }
}

runSimulations <- function(opt, likdat, spectrumData, numSimul) {

    shiny::withProgress(message = 'Running simulations', value = 0, {
        simul <- first90::simul.test(opt, spectrumData, nsir = numSimul, SIR = TRUE, progress = make_progress(numSimul), likdat = likdat)
    })

    simul
}

calculateHessian <- function(opt, likdat, spectrumData) {

    shiny::withProgress(message = 'Calculating Hessian matrix: this may take a while!',
                        detail="Please don't close your browser", value = 0, {

        j <- Counter$new(par = 0, iteration = 0)

        numDeriv::hessian(x=opt$par,
                        func=iterateHessian,
                        fp = spectrumData,
                        likdat = likdat,
                        i = j)
    })
}
