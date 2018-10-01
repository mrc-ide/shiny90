startNewWorkingSet <- function(wd) {
    enterText(wd$findElement("css", "#workingSetName"), "Selenium working set")
    Sys.sleep(0.5)
    wd$findElement("css", "#startNewWorkingSet")$clickElement()
    expectTextEqual("Selenium working set", wd$findElement("css", "#workingSet_name"))
}

uploadSpectrumFile <- function(wd, path = "../../../sample_files/Malawi_2018_version_8.PJNZ") {
    expectTextEqual("Upload spectrum file(s)", wd$findElement("css", inActivePane(".panelTitle")))
    fileUpload <- wd$findElement("css", "#spectrumFile")
    fileUpload$setElementAttribute("style", "display: inline")
    enterText(fileUpload, normalizePath(path))
    fileUpload$sendKeysToElement(list(key = "enter"))
}

uploadDigestFile <- function(wd, path = "../../../sample_files/testing1234.zip.shiny90") {
    fileUpload <- wd$findElement("css", "#digestUpload")
    fileUpload$setElementAttribute("style", "display: inline")
    enterText(fileUpload, normalizePath(path))
    fileUpload$sendKeysToElement(list(key = "enter"))
}