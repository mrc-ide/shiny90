library(shiny)
library(glue)

doAndRememberPath <- function(paths, path, func) {
    paths <- c(paths, path)
    func(path)
    paths
}

writeFilesForDigest <- function(workingSet, spectrumFilesState, surveyAndProgramData, readmeTemplate) {
    paths <- NULL
    paths <- doAndRememberPath(paths, "survey.csv", function(path) {
        write.csv(surveyAndProgramData$survey, file=path)
    })
    paths <- doAndRememberPath(paths, "program.csv", function(path) {
        write.csv(surveyAndProgramData$program, file=path)
    })
    paths <- doAndRememberPath(paths, "notes.txt", function(path) {
        file.writeText(path, workingSet$notes)
    })
    if (!is.null(spectrumFilesState$combinedData())) {
        paths <- doAndRememberPath(paths, "combined_spectrum_data.rds", function(path) {
            saveRDS(spectrumFilesState$combinedData(), file=path)
        })
    }
    paths <- doAndRememberPath(paths, "README.md", function(path) {
        content <- readmeTemplate
        content <- gsub("__TITLE__", workingSet$name, content)
        content <- gsub("__NOTES__", workingSet$notes, content)
        content <- gsub("__TIMESTAMP__", as.POSIXlt(Sys.time(), "UTC", "%Y-%m-%dT%H:%M:%S"), content)
        file.writeText(path, content)
    })
    paths
}

withDir <- function(dir, expr) {
    old_wd <- getwd()
    on.exit(setwd(old_wd))
    setwd(dir)
    evalq(expr)
}

handleLoad <- function(input, workingSet, surveyAndProgramData) {
    state <- reactiveValues()
    state$uploadRequested <- FALSE

    observeEvent(input$requestDigestUpload, {
        state$uploadRequested <- TRUE
    })
    observeEvent(input$cancelDigestUpload, {
        state$uploadRequested <- FALSE
    })
    observeEvent(input$digestUpload, {
        inFile <- input$digestUpload
        if (!is.null(inFile)) {
            state$uploadRequested <- FALSE
            scratch <- tempfile()
            unzip(inFile$datapath, exdir=scratch)
            workingSet$name <- gsub(".zip.shiny90$", "", inFile$name)
            withDir(scratch, {
                workingSet$notes <- file.readText("notes.txt")
                surveyAndProgramData$survey <- read.csv("survey.csv")
                surveyAndProgramData$program <- read.csv("program.csv")
            })
            print(scratch)
        }
    })

    list(
        state = state,
        workingSet = workingSet,
        surveyAndProgramData = surveyAndProgramData
    )
}

handleSave <- function(input, output, workingSet, spectrumFilesState, surveyAndProgramData) {
    output$digestDownload <- downloadHandler(
        filename = function() { glue("{workingSet$name}.zip.shiny90") },
        contentType = "application/zip",
        content = function(file) {
            readmeTemplate <- file.readText("template_for_digest_readme.md")
            scratch <- tempfile()
            dir.create(scratch)
            withDir(scratch, {
                paths <- writeFilesForDigest(workingSet, spectrumFilesState, surveyAndProgramData, readmeTemplate)
                zip(file, paths)
            })
            unlink(scratch, recursive=TRUE)
        }
    )
}
