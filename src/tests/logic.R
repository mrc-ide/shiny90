startNewWorkingSet <- function(wd) {
    enterText(wd$findElement("css", "#workingSetName"), "Selenium working set")
    Sys.sleep(0.5)
    wd$findElement("css", "#startNewWorkingSet")$clickElement()
    expectTextEqual("Selenium working set", wd$findElement("css", "#workingSet_name"))
}

uploadFile <- function(wd, dir = "../../../sample_files/", filename, inputId) {
    path <- paste(dir, filename, sep="")
    fileUpload <- wd$findElement("css", inputId)
    fileUpload$setElementAttribute("style", "display: inline")
    enterText(fileUpload, normalizePath(path))
    fileUpload$sendKeysToElement(list(key = "enter"))
}

uploadSpectrumFile <- function(wd, dir= "../../../sample_files/", filename = "Malawi_2018_version_8.PJNZ") {
    expectTextEqual("Upload spectrum file(s)", wd$findElement("css", inActivePane(".panelTitle")))

    uploadFile(wd, dir=dir, filename=filename, inputId="#spectrumFile")
}

uploadDigestFile <- function(wd, dir="../../../sample_files/", filename = "testing1234.zip.shiny90") {
    uploadFile(wd, dir=dir, filename=filename, inputId="#digestUpload")
}