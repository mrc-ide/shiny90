startNewWorkingSet <- function(wd) {
    workingSetName <- wd$findElement("css", "#workingSetName")
    waitForVisible(workingSetName)
    enterText(workingSetName, "Selenium working set")

    waitFor(function() {
        wd$findElement("css", "#startNewWorkingSet")$clickElement()
        getText(wd$findElement("css", "#workingSet_name")) == "Selenium working set"
    })
}

uploadFile <- function(wd, dir="../../../sample_files/", filename, inputId) {

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

verifyPJNZFileUpload <- function(filename) {
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)
    expectTextEqual("Uploaded PJNZ files", waitForChildElement(section, "h3"))

    uploadedFile <- section$findChildElement("css", "li span")
    waitForVisible(uploadedFile)
    expectTextEqual(filename, uploadedFile)

    # Check data tab
    checkTopLeftTableCellHasThisValue("Data", ".spectrum-combined-data", "2022")
}

editWorkingSetMetadata <- function(wd, name = NULL, notes = NULL) {
    wd$findElement("css", "a#editWorkingSet")$clickElement()
    if (!is.null(name)) {
        enterText(wd$findElement("css", "#editWorkingSet_name"), name, clear = TRUE)
    }
    if (!is.null(notes)) {
        enterText(wd$findElement("css", "#editWorkingSet_notes"), notes, clear = TRUE)
    }
    wd$findElement("css", "#editWorkingSet_update")$clickElement()
}

runModel <- function() {
    runModelButton <- wd$findElement("css", inActivePane("#runModel"))
    runModelButton$clickElement()
    waitForShinyToNotBeBusy(wd)
}

waitForDownloadedFile <- function(name) {
    downloadPath <- file.path(downloaded_files, name)
    waitFor(function() { file.exists(downloadPath) })
}
