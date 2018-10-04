startNewWorkingSet <- function(wd) {
    enterText(wd$findElement("css", "#workingSetName"), "Selenium working set")
    Sys.sleep(0.5)
    wd$findElement("css", "#startNewWorkingSet")$clickElement()
    expectTextEqual("Selenium working set", wd$findElement("css", "#workingSet_name"))
}

uploadFile <- function(wd, dir="../../../sample_files/", filename = "Malawi_2018_version_8.PJNZ", inputId) {

    path <- paste(dir, filename, sep="")

    fileUpload <- wd$findElement("css", inputId)
    fileUpload$setElementAttribute("style", "display: inline")

    enterText(fileUpload, normalizePath(path))
    fileUpload$sendKeysToElement(list(key = "enter"))
}

uploadSpectrumFile <- function(wd, dir="../../../sample_files/", filename = "Malawi_2018_version_8.PJNZ") {
    expectTextEqual("Upload spectrum file(s)", wd$findElement("css", inActivePane(".panelTitle")))
    uploadFile(wd, dir, filename, "#spectrumFile")
}

uploadDigestFile <- function(wd,dir="../../../sample_files/", filename = "testing1234.zip.shiny90") {
    uploadFile(wd, dir, filename, "#digestUpload")
}

verifyPJNZFileUpload <- function(filename) {
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)
    expectTextEqual("Uploaded PJNZ files", waitForChildElement(section, "h3"))

    uploadedFile <- section$findChildElement("css", "li span")
    waitForVisible(uploadedFile)
    expectTextEqual(filename, uploadedFile)
}