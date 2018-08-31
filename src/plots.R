plotTotalNumberOfTests <- function(fp, mod, likdat){

    out_nbtest = numberTested(fp, mod)
    yAxisLimits <- c(0, max(likdat$vctanc$tot, na.rm=TRUE)/1000 + max(likdat$vctanc$tot, na.rm=TRUE)/1000*0.2)

    plot(I(likdat$vctanc$tot/1000) ~ likdat$vctanc$year,
            pch=16,
            ylim=yAxisLimits,
            cex=1.5,
            ylab='Number of tests (in 1000s)',
            xlab='year',
            xlim=c(2000, 2017),
            main='Total number of tests')

    lines(I(out_nbtest$value/1000) ~ out_nbtest$year, lwd=2, col='steelblue4')
}


plotNumberOfPositiveTests <- function(fp, mod, likdat){

    out_nbtest_pos = numberTestedPositive(fp, mod)

    yAxisLimits <- c(0, max(likdat$vctanc_pos$tot, na.rm=TRUE)/1000 + +max(likdat$vctanc_pos$tot, na.rm=TRUE)/1000*0.2)

    plot(I(likdat$vctanc_pos$tot/1000) ~ likdat$vctanc_pos$year,
            pch=16,
            ylim=yAxisLimits,
            cex=1.5,
            ylab='Number of positive tests (in 1000s)',
            xlab='year', xlim=c(2000, 2017),
            main='Number of positive tests')

    lines(I(out_nbtest_pos$value/1000) ~ out_nbtest_pos$year, lwd=2, col='violetred4')

}

plotPercentageNegativeOfTested <- function(survey_dt, out_evertest) {

    out_negative = negativeTestData(survey_dt, out_evertest)

    out_f <- out_negative$out_f
    out_m <- out_negative$out_m
    dat_f <- out_negative$dat_f
    dat_m <- out_negative$dat_m

    plot(out_f$value ~ out_f$year, type='l',
            ylim=c(0,1),
            col='maroon',
            main="% negative of all ever tested",
            xlim=c(2000, 2017),
            ylab='% negative ever tested',
            xlab='Year',
            lwd=2)

    lines(out_m$value ~ out_m$year, col='navy', lwd=2)

    points(dat_f$est ~ dat_f$year, pch=15, col='maroon')
    points(dat_m$est ~ dat_m$year, pch=16, col='navy')

    segments(x0=dat_f$year, y0=dat_f$ci_l, x1=dat_f$year, y1=dat_f$ci_u, lwd=2, col='maroon')
    segments(x0=dat_m$year, y0=dat_m$ci_l, x1=dat_m$year, y1=dat_m$ci_u, lwd=2, col='navy')
}

plotPercentagePLHIVOfTested <- function(survey_dt, out_evertest) {

    out_positive = positiveTestData(survey_dt, out_evertest)

    out_f <- out_positive$out_f
    out_m <- out_positive$out_m
    dat_f <- out_positive$dat_f
    dat_m <- out_positive$dat_m

    plot(out_f$value ~ out_f$year,
            type='l',
            ylim=c(0,1),
            col='maroon',
            main='% PLHIV of all ever tested',
            xlim=c(2000, 2017),
            ylab='% PLHIV of ever tested',
            xlab='Year',
            lwd=2)

    lines(out_m$value ~ out_m$year, col='navy', lwd=2)

    points(dat_f$est ~ I(dat_f$year-0.1), pch=15, col='maroon')
    points(dat_m$est ~ I(dat_m$year+0.1), pch=16, col='navy')

    segments(x0=dat_f$year-0.1, y0=dat_f$ci_l, x1=dat_f$year-0.1, y1=dat_f$ci_u, lwd=2, col='maroon')
    segments(x0=dat_m$year+0.1, y0=dat_m$ci_l, x1=dat_m$year+0.1, y1=dat_m$ci_u, lwd=2, col='navy')
}

plotPercentageTested <- function(survey_dt, out_evertest) {

    out_all = allTestData(survey_dt, out_evertest)

    out_f <- out_all$out_f
    out_m <- out_all$out_m
    dat_f <- out_all$dat_f
    dat_m <- out_all$dat_m

    plot(out_f$value ~ out_f$year,
            type='l',
            ylim=c(0,1),
            col='maroon',
            main='% of population ever tested',
            xlim=c(2000, 2017),
            ylab='% ever tested',
            xlab='Year',
            lwd=2)

    lines(out_m$value ~ out_m$year, col='navy', lwd=2)

    points(dat_f$est ~ I(dat_f$year+0.1), pch=15, col='maroon')
    points(dat_m$est ~ I(dat_m$year-0.1), pch=16, col='navy')

    segments(x0=dat_f$year+0.1, y0=dat_f$ci_l, x1=dat_f$year+0.1, y1=dat_f$ci_u, lwd=2, col='maroon')
    segments(x0=dat_m$year-0.1, y0=dat_m$ci_l, x1=dat_m$year-0.1, y1=dat_m$ci_u, lwd=2, col='navy')
}

plotFirstAndSecond90 <- function(fp, mod, out_evertest) {

    out = first90Data(fp, mod)

    out_a <- out$out_a

    out_ever_all <- subset(out_evertest, agegr == '15-49' & outcome == 'evertest' & sex == 'both' & hivstatus == 'positive')

    out_art <- out$out_art

    plot(out_a$value ~ out_a$year,
            type='l',
            ylim=c(0,1),
            col='darkslategrey',
            main='First and second 90',
            xlim=c(2000, 2017),
            ylab='%',
            xlab='Year',
            lwd=2)

    lines(out_art$value ~ out_art$year, col='deepskyblue2', lwd=2, lty=1)
    lines(out_ever_all$value ~ out_ever_all$year, col='orange3', lwd=2, lty=1)

    legend(x=2000, y=0.95, legend = c('PLHIV Ever Tested','PLHIV Aware','ART Cov'),
    col=c('orange3','darkslategrey','deepskyblue2'), lwd=3, bty='n')
}