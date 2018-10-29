startNewWorkingSet <- function(wd) {
    workingSetName <- wd$findElement("css", "#workingSetName")
    waitForVisible(workingSetName)
    enterText(workingSetName, "Selenium working set")

    Sys.sleep(0.5)

    waitFor(function() {
        wd$findElement("css", "#startNewWorkingSet")$clickElement()
        getText(wd$findElement("css", "#workingSet_name")) == "Selenium working set"
    })

}

uploadFile <- function(wd, dir="../../../sample_files/", filename, inputId) {

    path <- paste(dir, filename, sep="")

    fileUpload <- wd$findElement("css", inputId)
    fileUpload$setElementAttribute("style", "display: inline")

    filePath <- normalizePath(path)
    enterText(fileUpload, filePath)

    Sys.sleep(0.5)
    fileUpload$sendKeysToElement(list(key = "enter"))
}

uploadSpectrumFile <- function(wd, dir="../../../sample_files/", filename = "Malawi_2018_version_8.PJNZ") {
    expectTextEqual("Upload spectrum file(s)", wd$findElement("css", inActivePane(".panelTitle")))
    uploadFile(wd, dir, filename, "#spectrumFile")
}

verifyPJNZFileUpload <- function(filename) {
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")

    waitFor(function(){
        heading <- waitForChildElement(section, "h3")
        getText(heading) == "Uploaded PJNZ files"
    })

    uploadedFile <- waitForChildElement(section, "li > span")

    waitForAndTryAgain(function(){
        isVisible(uploadedFile)
    }, failureCallBack = function(){
        uploadSpectrumFile(wd, dir="../../../sample_files/", filename)
    })

    expectTextEqual(filename, uploadedFile)

    # Check data tab
    checkTopLeftTableCellHasThisValue("Data", ".spectrum-combined-data", "2022")
}

editWorkingSetMetaInner <- function(wd, name, notes = NULL){
    wd$findElement("css", "a#editWorkingSet")$clickElement()

    enterText(wd$findElement("css", "#editWorkingSet_name"), name, clear = TRUE)

    if (!is.null(notes)) {
        enterText(wd$findElement("css", "#editWorkingSet_notes"), notes, clear = TRUE)
    }

    wd$findElement("css", "#editWorkingSet_update")$clickElement()
}

editWorkingSetMetadata <- function(wd, name, notes = NULL) {

    editWorkingSetMetaInner(wd, name, notes)

    waitForAndTryAgain(function() {
        getText(wd$findElement("css", "#workingSet_name")) == name
    }, failureCallBack = function() {
       editWorkingSetMetaInner(wd, name, notes)
    })
}

runModel <- function(numSimulations) {

    runModelButton <- wd$findElement("css", inActivePane("#runModel"))

    wd$findElement("css", "#showAdvancedOptions")$clickElement()
    numSimul <- waitForElement(wd, "#numSimul")

    enterText(numSimul, "0")

    runModelButton$clickElement()
    waitForShinyToNotBeBusy(wd)
}

waitForDownloadedFile <- function(name) {
    downloadPath <- file.path(downloadedFiles, name)
    waitFor(function() { file.exists(downloadPath) })
}

downloadFileFromLink <- function(link, name) {
    waitForShinyToNotBeBusy(wd)
    waitFor(function() {
        link$clickElement()
        downloadPath <- file.path(downloadedFiles, name)
        Sys.sleep(0.1)
        file.exists(downloadPath)
    })
}

uploadSpectrumFileAndSwitchTab <- function(tabName, filename= "Malawi_2018_version_8.PJNZ") {
    wd$navigate(appURL)

    startNewWorkingSet(wd)

    uploadSpectrumFile(wd, filename = filename)
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    switchTab(wd, tabName)
}
