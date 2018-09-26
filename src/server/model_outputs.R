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
    theta0 <- c(rep(log(0.1), 18), # Males: log of testing rates in 2005, 2010, and 2015
                rep(log(0.2), 18), # Females: log of testing rates in 2005, 2010, and 2015
                log(1.5),   # Factor increase among previously tested
                log(0.8),   # Factor testing among diagnosed, untreated
                log(0.2),   # Fractor testing among diagnosed, on ART
                rep(log(0.5), 2)) # Rate ratio for testing in the 25+ age group

    first90::ll_hts(theta0, fp, likdat)

    opt <- optim(theta0, first90::ll_hts, fp = fp, likdat = likdat, method="BFGS",
                    control=list(fnscale = -1, trace=4, REPORT=1, maxit=250))

    round(exp(opt$par[1:36]), 3)
    fp <- first90::create_hts_param(opt$par, fp)

    return(list("fp" = fp, "likdat" = likdat))
}

outEverTest <- function(fp, mod) {

    out_evertest <- expand.grid(year = 2000:2022,
                                outcome = "evertest",
                                agegr = c("15-24", "25-49", '15-49'),
                                sex = c("both", "female", "male"),
                                hivstatus = c("all", "negative", "positive"))

    out_evertest$value <- first90::evertest(mod, fp, first90::add_ss_indices(out_evertest, fp$ss))

    out_evertest
}

numberTested <- function(fp, mod) {

    out_nbtest <- expand.grid(year=2000:2022,
                            outcome = "numbertests",
                            agegrp="15-99",
                            sex="both",
                            hivstatus='all')

    out_nbtest$value <- first90::number_tests(mod, fp, first90::add_ss_indices(out_nbtest, fp$ss))$tests

    out_nbtest
}

numberTestedPositive <- function(fp, mod) {

    out_nbtest_pos <- expand.grid(year=2000:2022,
                                outcome = "numbertests",
                                agegrp="15-99",
                                sex="both",
                                hivstatus='positive')

    out_nbtest_pos$value <- first90::number_tests(mod, fp, first90::add_ss_indices(out_nbtest_pos, fp$ss))$tests

    out_nbtest_pos
}

negativeTestData <- function(survey_dt, out_evertest) {

    out_f <- subset(out_evertest, agegr == '15-49' & outcome == 'evertest' & sex =='female' & hivstatus == 'negative')
    out_m <- subset(out_evertest, agegr == '15-49' & outcome == 'evertest' & sex =='male' & hivstatus == 'negative')
    dat_f <- subset(survey_dt, agegr == '15-49' & sex == 'female' & hivstatus == 'negative' & outcome == 'evertest')
    dat_m <- subset(survey_dt, agegr == '15-49' & sex == 'male' & hivstatus == 'negative' & outcome == 'evertest')

    return(list("out_f" = out_f,
                "out_m" = out_m,
                "dat_f" = dat_f,
                "dat_m" = dat_m))
}

positiveTestData <- function(survey_dt, out_evertest) {

    out_f <- subset(out_evertest, agegr == '15-49' & outcome == 'evertest' & sex =='female' & hivstatus == 'positive')
    out_m <- subset(out_evertest, agegr == '15-49' & outcome == 'evertest' & sex =='male' & hivstatus == 'positive')
    dat_f <- subset(survey_dt, agegr == '15-49' & sex == 'female' & hivstatus == 'positive' & outcome == 'evertest')
    dat_m <- subset(survey_dt, agegr == '15-49' & sex == 'male' & hivstatus == 'positive' & outcome == 'evertest')

    return(list("out_f" = out_f,
                "out_m" = out_m,
                "dat_f" = dat_f,
                "dat_m" = dat_m))
}

allTestData <- function(survey_dt, out_evertest){

    out_f <- subset(out_evertest, agegr == '15-49' & outcome == 'evertest' & sex =='female' & hivstatus == 'all')
    out_m <- subset(out_evertest, agegr == '15-49' & outcome == 'evertest' & sex =='male' & hivstatus == 'all')
    dat_f <- subset(survey_dt, agegr == '15-49' & sex == 'female' & hivstatus == 'all' & outcome == 'evertest')
    dat_m <- subset(survey_dt, agegr == '15-49' & sex == 'male' & hivstatus == 'all' & outcome == 'evertest')

    return(list("out_f" = out_f,
        "out_m" = out_m,
        "dat_f" = dat_f,
        "dat_m" = dat_m))
}

first90Data <- function(fp, mod) {

    out <- expand.grid(year = 2000:2022,
                        outcome = 'aware',
                        agegr = '15-49',
                        sex = c("both", "female", "male"),
                        hivstatus = 'positive')

    out$value <- first90::diagnosed(mod, fp, first90::add_ss_indices(out, fp$ss))

    out_art <- data.frame(year = 1970:2022,
                            outcome = "artcov",
                            agegr = "15-49",
                            sex = "both", hivstatus = "positive",
                            value = artcov15to49(mod))

    out_f <- subset(out, agegr == '15-49' & outcome == 'aware' & sex =='female')
    out_m <- subset(out, agegr == '15-49' & outcome == 'aware' & sex =='male')
    out_a <- subset(out, agegr == '15-49' & outcome == 'aware' & sex =='both')

    return(list("out_f" = out_f,
                "out_m" = out_m,
                "out_a" = out_a,
                "out_art" = out_art))
}