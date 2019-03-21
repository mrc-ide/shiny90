handleDownloads <- function(input, output, workingSet, spectrumFilesState, surveyAndProgramData, modelRunState) {
  output$plotsDownload <- downloadPlots(workingSet, spectrumFilesState, surveyAndProgramData, modelRunState)
  output$tablesDownload <- downloadTables(input, workingSet, spectrumFilesState, surveyAndProgramData, modelRunState)
}

downloadPlots <- function(workingSet, spectrumFilesState, surveyAndProgramData, modelRunState) {
  
  shiny::downloadHandler(
    filename = function() {
      name <- gsub(" ", "", workingSet$name())
      glue::glue("{name}_plots.pdf")
    },
    contentType = "application/pdf",
    content = function(file) {
      writePlotsForDownload(workingSet, spectrumFilesState, surveyAndProgramData,
                            modelRunState, readmeTemplate, file)
    }
  )
}

downloadTables <- function(input, workingSet, spectrumFilesState, surveyAndProgramData, modelRunState) {
  
  shiny::downloadHandler(
    filename = function() {
      name <- gsub(" ", "", workingSet$name())
      glue::glue("{name}_tables.xlsx")
    },
    contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    content = function(file) {
      writeTablesForDownload(input, workingSet, spectrumFilesState, surveyAndProgramData,
                             modelRunState, readmeTemplate, file)
    }
  )
}

writePlotsForDownload <- function(workingSet, spectrumFilesState, surveyAndProgramData, modelRunState, readmeTemplate, path) {
  pdf(file = path)
  on.exit(dev.off())
  layout(matrix(seq_len(4), ncol = 2, byrow = TRUE))
  on.exit(layout(1), add = TRUE)
  if (surveyAndProgramData$anyProgramDataTot()) {
    first90::plot_input_tot(surveyAndProgramData$program_data, spectrumFilesState$combinedData())
  }
  if (surveyAndProgramData$anyProgramDataTotPos()) {
    first90::plot_input_totpos(surveyAndProgramData$program_data, spectrumFilesState$combinedData())
  }
  if (surveyAndProgramData$anyProgramDataAnc()) {
    first90::plot_input_anctot(surveyAndProgramData$program_data, spectrumFilesState$combinedData())
  }
  if (surveyAndProgramData$anyProgramDataAncPos()) {
    first90::plot_input_ancpos(surveyAndProgramData$program_data, spectrumFilesState$combinedData())
  }
  if (spectrumFilesState$anyDataPrv()) {
    first90::plot_pjnz_prv(spectrumFilesState$pjnz_summary())
  }
  if (spectrumFilesState$anyDataInc()) {
    first90::plot_pjnz_inc(spectrumFilesState$pjnz_summary())
  }
  if (spectrumFilesState$anyDataPop()) {
    first90::plot_pjnz_pop(spectrumFilesState$pjnz_summary())
  }
  if (spectrumFilesState$anyDataPlhiv()) {
    first90::plot_pjnz_plhiv(spectrumFilesState$pjnz_summary())
  }
  if (modelRunState$state == "converged" && !is.null(modelRunState$optim)) {
    mod <- modelRunState$mod
    fp <- modelRunState$fp
    likdat <- modelRunState$likelihood()
    country <- spectrumFilesState$countryAndRegionName()
    out_evertest <- first90::get_out_evertest(mod, fp)
    simul <- modelRunState$simul
    surveyAsDataTable <- modelRunState$surveyAsDataTable()
    
    first90::plot_out_nbtest(mod, fp, likdat, country, simul)
    first90::plot_out_nbpostest(mod, fp, likdat, country, simul)
    first90::plot_out_evertestneg(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    first90::plot_out_evertestpos(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    first90::plot_out_evertest(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    first90::plot_out_90s(mod, fp, likdat, country, out_evertest, surveyAsDataTable, simul)
    first90::plot_out_evertest_fbyage(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    first90::plot_out_evertest_mbyage(mod, fp, likdat, country, surveyAsDataTable, out_evertest, simul)
    
    first90::plot_retest_test_neg(mod, fp, likdat, country)
    first90::plot_retest_test_pos(mod, fp, likdat, country)
    first90::plot_prv_pos_yld(mod, fp, likdat, country, yr_pred = 2018)
  }
}

writeTablesForDownload <- function(input, workingSet, spectrumFilesState, surveyAndProgramData, modelRunState, readmeTemplate, path) {
  sheets <- list(
    "Knowledge of status (%)" = getTableAware(input)(modelRunState),
    "Knowledge of status (absolute)" = getTableNbAware(input)(modelRunState),
    "ART coverage" = getTableArtCoverage(input)(modelRunState),
    "Proportion ever tested" = getTableEverTested(input)(modelRunState),
    "Estimated parameters" = first90::optimized_par(modelRunState$optim),
    "Pregnant women" = first90::tab_out_pregprev(modelRunState$mod, modelRunState$fp)
  )
  writexl::write_xlsx(sheets, path = path)
}