fitModel <- function(survey_data, program_data, fp, country){

    # Prepare survey data for ever tested for HIV.
    age_group <- c('15-24','25-34','35-49')
    dat <- first90::select_hts(survey_data, country, age_group)

    # We create the likelihood data
    likdat <- first90::prepare_hts_likdat(dat, program_data, fp)

    # Starting parameters
    data("theta0", package="first90")

    first90::ll_hts(theta0, fp, likdat)

    maxIterations <- 250
    if (Sys.getenv("SHINY90_TEST_MODE") == "TRUE") {
        maxIterations <- 2
    }

    opt <- optim(theta0, first90::ll_hts, fp = fp, likdat = likdat, method="BFGS",
                    control=list(fnscale = -1, trace=4, REPORT=1, maxit=maxIterations))

    fp <- first90::create_hts_param(opt$par, fp)
    mod <- eppasm::simmod.specfp(fp)

    return(list("fp" = fp, "likdat" = likdat, "mod" = mod))
}
