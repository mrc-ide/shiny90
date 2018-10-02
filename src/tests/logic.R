startNewWorkingSet <- function(wd) {
    enterText(wd$findElement("css", "#workingSetName"), "Selenium working set")
    Sys.sleep(0.5)
    wd$findElement("css", "#startNewWorkingSet")$clickElement()
    expectTextEqual("Selenium working set", wd$findElement("css", "#workingSet_name"))
}

uploadFile <- function(wd, path, inputId) {
    fileUpload <- wd$findElement("css", inputId)
    fileUpload$setElementAttribute("style", "display: inline")
    enterText(fileUpload, normalizePath(path))
    fileUpload$sendKeysToElement(list(key = "enter"))
}

uploadSpectrumFile <- function(wd, path = "../../../sample_files/Malawi_2018_version_8.PJNZ") {
    expectTextEqual("Upload spectrum file(s)", wd$findElement("css", inActivePane(".panelTitle")))

    uploadFile(wd, path, "#spectrumFile")
}

uploadDigestFile <- function(wd, path = "../../../sample_files/testing1234.zip.shiny90") {
    uploadFile(wd, path, "#digestUpload")
}