prepareProgramInput <- function(program_data) {

    prgm_dat <- program_data
    prgm_tot <- program_data$number[program_data$type == 'NbTested'] + program_data$number[program_data$type == 'NbANCTested']
    prgm_pos <- program_data$number[program_data$type == 'NbTestPos'] + program_data$number[program_data$type == 'NBTestedANCPos']
    year <- unique(prgm_dat$year)
    prg_dat <- data.frame(year=year, tot=prgm_tot, pos=prgm_pos, agegr='15-99', sex='both', hivstatus='all')

    prg_dat
}

prepareSurveyInput <- function(survey_dt) {

    age_group <- c('15-24','25-49')

    dat_f <- survey_dt[(hivstatus != "all") & (agegr %in% age_group) & sex == "female" & outcome == "evertest"]

    dat_m <- survey_dt[(hivstatus != "all") & (agegr %in% age_group) & sex == "male" & outcome == "evertest"]

    other_survey <- unique(rbind(dat_f, dat_m)$surveyid)

    dat_fall <- survey_dt[hivstatus == "all" & !(surveyid %in% other_survey) &
        (agegr %in% age_group) & sex == "female" & outcome == "evertest"]

    dat_mall <- survey_dt[hivstatus == "all" & !(surveyid %in% other_survey) &
        (agegr %in% age_group) & sex == "male" & outcome == "evertest"]

    dat <- rbind(dat_f, dat_m, dat_fall, dat_mall)
    dat
}

fitModel <- function(survey_data, program_data, fp){
    # Prepare survey data for ever tested for HIV.
    dat <- prepareSurveyInput(survey_data)

    # We prepare the program data
    prg_dat <- prepareProgramInput(program_data)

    # We create the likelihood data
    likdat <- first90::prepare_hts_likdat(dat, prg_dat, fp)

    # Starting parameters
    theta0 <- c(log(seq(0.01, 0.1, length.out = 18)), # Females 15-24 baseline testing rate
                boot::logit(c(0.7,0.6)),
                boot::logit(1/1.5),   # Factor increase among previously tested
                log(0.8),   # Factor testing among diagnosed, untreated
                log(0.2),   # Fractor testing among diagnosed, on ART
                rep(log(0.5), 2), # Males: rate ratio for 25-34
                rep(log(0.5), 2), # Females: Rate ratio for testing in the 35+ age group
                boot::logit(0.75)) # Proportion of OI tested for HIV in 2010 (assumed to be 95% in 2015)

    first90::ll_hts(theta0, fp, likdat)

    maxIterations <- 250
    if (Sys.getenv("SHINY90_TEST_MODE") == "TRUE") {
        maxIterations <- 2
    }

    opt <- optim(theta0, first90::ll_hts, fp = fp, likdat = likdat, method="BFGS",
                    control=list(fnscale = -1, trace=4, REPORT=1, maxit=maxIterations), hessian=TRUE)

    simul <- first90::simul.test(opt,  fp, sim=400)

    fp <- first90::create_hts_param(opt$par, fp)
    mod <- eppasm::simmod.specfp(fp)

    #optimized_par(opt)

    return(list("mod" = mod, "fp" = fp, "likdat" = likdat, simul = "simul"))
}
