fitModel <- function(maxIterations, likelihood, spectrumData) {
    # Starting parameters
    data("theta0", package="first90")

    testMode <- Sys.getenv("SHINY90_TEST_MODE") == "TRUE"

    if (testMode) {
        maxIterations <- 2
    }

    opt <- NULL

    shiny::withProgress(message = 'Fitting model', value = 0, {

        i <- Counter$new(value = 0)

        opt <- optim(
            theta0,
            iterate,
            fp = spectrumData,
            likdat = likelihood,
            maxIt = maxIterations*90,
            i = i,
            method = "BFGS",
            control = list(fnscale = -1, trace=4, REPORT=1, maxit=maxIterations)
        )

    })

    shiny::withProgress(message = 'Calculating Hessian matrix: this may take a while!', value = 0, {

        j <- Counter$new(value = 0)

        opt$hessian <- numDeriv::hessian(x=opt$par,
                                        func=iterateHessian,
                                        fp = spectrumData,
                                        likdat = likelihood,
                                        i = j)
    })

    opt
}

invert <- function(f) function(...) -f(...)

Counter <- methods::setRefClass("Counter",
                fields=list(
                    value="numeric"
                ))

makeCounter <- function() {
    value <- 0
    function() {
        value <<- value + 1
        value
    }
}

iterate <- function(theta, fp, likdat, maxIt, i){
    if (i$value %% 90 == 0){
        shiny::incProgress((1/(maxIt)), detail= paste("Iteration ", i$value/90))
    }
    else {
        shiny::incProgress((1/(maxIt)))
    }

    i$value <- i$value + 1
    first90::ll_hts(theta, fp, likdat)
}


iterateHessian <- function(theta, fp, likdat, i){

    shiny::incProgress(1/7300)
    i$value <- i$value + 1

    first90::ll_hts(theta, fp, likdat)
}

runSimulations <- function(opt, spectrumData) {
    testMode <- Sys.getenv("SHINY90_TEST_MODE") == "TRUE"
    simul <- NULL
    if (!testMode) {

        shiny::withProgress(message = 'Running simulations', value = 0, {

            i <- Counter$new(value = 0)
            simul <- first90::simul.test(opt, spectrumData)
        })
    }

    simul
}