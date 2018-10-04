prepareProgramInput <- function(program_data) {

    prgm_dat <- program_data
    prgm_tot <- program_data$number[program_data$type == 'NbTested'] + program_data$number[program_data$type == 'NbANCTested']
    prgm_pos <- program_data$number[program_data$type == 'NbTestPos'] + program_data$number[program_data$type == 'NBTestedANCPos']
    year <- unique(prgm_dat$year)
    prg_dat <- data.frame(year=year, tot=prgm_tot, pos=prgm_pos, agegr='15-99', sex='both', hivstatus='all')

    prg_dat
}

fitModel <- function(survey_data, program_data, fp, country){

    # Prepare survey data for ever tested for HIV.
    age_group <- c('15-24','25-49')
    dat <- first90::select_hts(survey_data, country, age_group)

    # We prepare the program data
    prg_dat <- prepareProgramInput(program_data)

    # We create the likelihood data
    likdat <- first90::prepare_hts_likdat(dat, prg_dat, fp)

    # Starting parameters
    data("theta0", package="first90")

    first90::ll_hts(theta0, fp, likdat)

    maxIterations <- 250
    if (Sys.getenv("SHINY90_TEST_MODE") == "TRUE") {
        maxIterations <- 2
    }

    opt <- optim(theta0, first90::ll_hts, fp = fp, likdat = likdat, method="BFGS",
                    control=list(fnscale = -1, trace=4, REPORT=1, maxit=maxIterations))

    round(exp(opt$par[1:36]), 3)
    fp <- first90::create_hts_param(opt$par, fp)
    mod <- eppasm::simmod.specfp(fp)

    return(list("fp" = fp, "likdat" = likdat, "mod" = mod))
}
