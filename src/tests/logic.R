startNewWorkingSet <- function(wd) {

    waitFor(function() {
        wd$findElement("css", "#startNewWorkingSet")$clickElement()
        isVisible(wd$findElement("css", "#workingSet_name"))
    })
}

loadDigest <- function(wd, dir, filename, selector) {
    waitFor(function() {
        loadButton <- wd$findElement("css", selector)
        loadButton$clickElement()

        modal <- wd$findElement("css", "#digestModal .modal-dialog")
        isVisible(modal)
    })

    uploadFile(wd, dir, filename, "#digestUpload")
    waitForVisible(wd$findElement("css", "#workingSet_name"))
}

loadDigestFromWelcome <- function(wd, dir="../../../sample_files/", filename = "Malawi.zip.shiny90") {
    loadDigest(wd, dir, filename, "#welcomeRequestDigestUpload")
}

loadDigestFromMainUI <- function(wd, dir="../../../sample_files/", filename = "Malawi.zip.shiny90") {
    loadDigest(wd, dir, filename, "#requestDigestUpload")
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

uploadNewSpectrumFile <- function(wd, filename = "Togo_Centrale_2018.PJNZ") {
    switchTab(wd, "Upload spectrum file(s)")

    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")
    waitForVisible(section)

    files <- waitForThisManyChildren(section, "li", 1)
    files[[1]]$findChildElement("css", "button")$clickElement()
    files <- waitForThisManyChildren(section, "li", 0)

    uploadSpectrumFile(wd, filename = filename)
    waitForVisible(section)

    expectTextEqual(filename, waitForChildElement(section, "li > span"))
}

verifyPJNZFileUpload <- function(filename) {
    section <- wd$findElement("css", ".uploadedSpectrumFilesSection")

    waitFor(function(){
        heading <- waitForChildElement(section, "h3")
        getText(heading) == "Uploaded Spectrum files"
    })

    uploadedFile <- waitForChildElement(section, "li > span")

    waitForAndTryAgain(function(){
        isVisible(uploadedFile)
    }, failureCallBack = function(){
        uploadSpectrumFile(wd, dir="../../../sample_files/", filename)
    })

    expectTextEqual(filename, uploadedFile)

    # Check data tab
    checkTopLeftTableCellHasThisValue("Data", ".spectrum-combined-data", "2000")
}

editWorkingSetMetaInner <- function(wd,notes){
    wd$findElement("css", "a#editWorkingSet")$clickElement()

    enterText(wd$findElement("css", "#editWorkingSet_notes"), notes, clear = TRUE)

    wd$findElement("css", "#editWorkingSet_update")$clickElement()
}

editWorkingSetMetadata <- function(wd, notes) {

    editWorkingSetMetaInner(wd, notes)

    waitForAndTryAgain(function() {
        getText(wd$findElement("css", "#workingSet_notes")) == notes
    }, failureCallBack = function() {
       editWorkingSetMetaInner(wd, notes)
    })
}

runModel <- function() {

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
