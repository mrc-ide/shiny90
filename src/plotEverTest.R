# everTestOutput <- function(survey_data, program_data, pjnz_path) {
#
#     fp <- prepare_inputs(pjnz_path)
#
#     likdat <- prepare_hts_likdat(survey_data, program_data, fp)
#
#     theta0 <- c(- 4.0, - 1.5, - 1.6)
#
#     ll_hts(theta0, fp, likdat)
#     #> [1] -1181.627
#
#     opt <- optim(theta0, ll_hts, fp = fp, likdat = likdat, method = "BFGS", control = list(fnscale = - 1, trace = 4, REPORT = 1),
#     hessian = TRUE)
#     #> initial  value 1181.626777
#     #> iter   2 value 572.255026
#     #> iter   3 value 286.693607
#     #> iter   4 value 279.140257
#     #> iter   5 value 57.551039
#     #> iter   6 value 51.423116
#     #> iter   7 value 50.634869
#     #> iter   8 value 50.383888
#     #> iter   9 value 50.364602
#     #> iter  10 value 50.341156
#     #> iter  11 value 50.333926
#     #> iter  12 value 50.328661
#     #> iter  12 value 50.328660
#     #> iter  12 value 50.328660
#     #> final  value 50.328660
#     #> converged
#
#     fp <- create_hts_param(opt$par, fp)
#     mod <- simmod(fp)
#
#     out_evertest <- expand.grid(year = 2000 : 2020,
#     outcome = "evertest",
#     agegr = "15-49",
#     sex = "both",
#     hivstatus = c("all", "negative", "positive"))
#     out_evertest$value <- evertest(mod, fp, add_ss_indices(out_evertest, fp$ss))
#
#     out <- rbind(out_evertest,
#     data.frame(year = 1970 : 2022, outcome = "aware", agegr = "15-49", sex = "both", hivstatus = "positive", value = diagnosed(mod)),
#     data.frame(year = 1970 : 2022, outcome = "artcov", agegr = "15-49", sex = "both", hivstatus = "positive", value = artcov15to49(mod)))
#
#     out
# }