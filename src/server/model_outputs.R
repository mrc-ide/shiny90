fitModelInner <- function(maxIterations, likelihood, spectrumData) {
    # Starting parameters
    data("theta0", package="first90")

    if (testMode) {
        maxIterations <- 2
    }

    opt <- NULL

    shiny::withProgress(message = 'Fitting model', value = 0, {

        maxRuns <- maxIterations*2*length(theta0)
        # this is a heuristic for how many times the model is run by optim

        opt <- optim(
            theta0,
            iterate,
            fp = spectrumData,
            likdat = likelihood,
            progress = makeProgressFittingModel(maxRuns, theta0),
            method = "BFGS",
            control = list(fnscale = -1, trace=4, REPORT=1, maxit=maxIterations)
        )

    })

    opt
}

testMode <- Sys.getenv("SHINY90_TEST_MODE") == "TRUE"

iterate <- function(theta, fp, likdat, progress){

    val <- first90::ll_hts(theta, fp, likdat)
    progress(theta, val)
    val
}

makeProgressFittingModel <- function(n, theta0) {
    params <- theta0
    function(theta, val) {

        if (isGradientStep(theta, params) || is.nan(val)) {
            shiny::incProgress(1/n)
        }
        else {
            params <<- theta
            shiny::incProgress((1/n), detail= paste("Converging: ", round(val, 2)))
        }
    }
}

isGradientStep <- function(theta1, theta2){
    length(which(theta1 != theta2)) < 2
}

makeHessianProgress <- function(n) {
    step <- 0L
    time <- Sys.time()
    function() {
        if (step == 0L){
            time <<- Sys.time()
        }
        step <<- step + 1L
        estimatedTimeLeft <- (difftime(Sys.time(),time,units="secs")/ step) * (n - step)
        shiny::incProgress(1/n, detail = glue::glue("Estimated time left: {round(estimatedTimeLeft)} seconds"))
    }
}

iterateHessian <- function(theta, fp, likdat, progress){
    progress()
    first90::ll_hts(theta, fp, likdat)
}

makeProgress <- function(n, every = 0.1) {
    counter <- 0L
    last_time <- as.numeric(Sys.time()) - every * 2
    last_counter <- 0L
    function() {
        counter <<- counter + 1L
        now <- as.numeric(Sys.time())
        if (counter >= n || now - last_time > every) {
            inc <- (counter - last_counter) / n
            shiny::incProgress(inc, detail = glue::glue("Running simulation {counter} of {n}"))
            last_time <<- now
            last_counter <<- counter
        }
    }
}

runSimulations <- function(opt, likdat, spectrumData, numSimul) {

    shiny::withProgress(message = 'Running simulations', value = 0, {
        simul <- first90::simul.test(opt, spectrumData, nsir = numSimul - 1, SIR = TRUE, progress = makeProgress(numSimul), likdat = likdat)
    })

    simul
}

calculateHessianInner <- function(opt, likdat, spectrumData) {

    shiny::withProgress(message = 'Calculating Hessian matrix: this may take a while!',
                        value = 0, {
        numDeriv::hessian(x=opt$par,
                        func=iterateHessian,
                        fp = spectrumData,
                        likdat = likdat,
                        progress = makeHessianProgress(7300)) # 7300 is an approximation of how many times the model will be run
    })
}

fitModel <- memoise::memoise(fitModelInner)
calculateHessian <- memoise::memoise(calculateHessianInner)