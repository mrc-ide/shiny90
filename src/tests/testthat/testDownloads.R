library(methods)
testthat::context("downloads")

testthat::test_that("model run outputs can be downloaded", {
  uploadSpectrumFileAndSwitchTab("Upload survey data")
  uploadFile(wd, filename = "fakesurvey_malawi.csv", inputId="#surveyData")
  
  switchTab(wd, "Run model")
  runModel()
  
  plots_download = wd$findElement("css", inActivePane("#plotsDownload"))
  expectTextEqual("Download plots as PDF", plots_download)
  downloadFileFromLink(plots_download, "Malawi_plots.pdf")
  
  tables_download = wd$findElement("css", inActivePane("#tablesDownload"))
  expectTextEqual("Download tables as XLSX", tables_download)
  downloadFileFromLink(tables_download, "Malawi_tables.xlsx")
  
  removeFile("Malawi_plots.pdf")
  removeFile("Malawi_tables.xlsx")
})