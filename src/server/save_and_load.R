doAndRememberPath <- function(paths, path, func) {
    paths <- c(paths, path)
    func(path)
    paths
}

removeExtension <- function(path, extension) {
    regexp <- glue::glue(".{extension}$")
    gsub(regexp, "", path)
}

writeFilesForDigest <- function(workingSet, spectrumFilesState, surveyAndProgramData, readmeTemplate) {
    paths <- NULL
    paths <- doAndRememberPath(paths, "survey.csv", function(path) {
        write.csv(surveyAndProgramData$survey, file = path)
    })
    paths <- doAndRememberPath(paths, "program.csv", function(path) {
        write.csv(surveyAndProgramData$program_wide, file = path, row.names = FALSE)
    })
    paths <- doAndRememberPath(paths, "notes.txt", function(path) {
        file.writeText(path, workingSet$notes)
    })
    dir.create("spectrum_data")
    paths <- purrr::reduce(spectrumFilesState$dataSets, .init = paths, function(paths, dataSet) {
        path <- file.path("spectrum_data", glue::glue("{dataSet$name}.rds"))
        doAndRememberPath(paths, path, function(path) {
            saveRDS(dataSet$data, file = path)
        })
    })
    paths <- doAndRememberPath(paths, "country.txt", function(path) {
        file.writeText(path, spectrumFilesState$country)
    })

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

handleSave <- function(input, output, workingSet, spectrumFilesState, surveyAndProgramData) {
    output$digestDownload <- shiny::downloadHandler(
        filename = function() { glue::glue("{workingSet$name}.zip.shiny90") },
        contentType = "application/zip",
        content = function(file) {
            readmeTemplate <- file.readText("template_for_digest_readme.md")
            scratch <- tempfile()
            dir.create(scratch)
            withDir(scratch, {
                paths <- writeFilesForDigest(workingSet, spectrumFilesState, surveyAndProgramData, readmeTemplate)
                zip(file, paths)
            })
            unlink(scratch, recursive = TRUE)
        }
    )
}

handleLoad <- function(input, workingSet, surveyAndProgramData, spectrumFilesState) {
    state <- shiny::reactiveValues()
    state$uploadRequested <- FALSE

    shiny::observeEvent(input$requestDigestUpload, { state$uploadRequested <- TRUE })
    shiny::observeEvent(input$welcomeRequestDigestUpload, { state$uploadRequested <- TRUE })
    shiny::observeEvent(input$cancelDigestUpload, {
        state$uploadRequested <- FALSE
    })
    shiny::observeEvent(input$digestUpload, {
        inFile <- input$digestUpload
        if (!is.null(inFile)) {
            state$uploadRequested <- FALSE
            scratch <- tempfile()
            unzip(inFile$datapath, exdir = scratch)
            workingSet$name <- removeExtension(inFile$name, "zip.shiny90$")
            withDir(scratch, {
                spectrumFilesState$country <- gsub("[\r\n]", "", file.readText("country.txt"))
                workingSet$notes <- file.readText("notes.txt")
                surveyAndProgramData$survey <- read.csv("survey.csv")
                surveyAndProgramData$program_wide <- read.csv("program.csv")
                spectrumFilesState$dataSets <- purrr::map(list.files("spectrum_data"), function(path) {
                    list(
                        name = removeExtension(path, "rds"),
                        data = readRDS(file.path("spectrum_data", path))
                    )
                })
            })
        }
    })

    list(
        state = state,
        workingSet = workingSet,
        surveyAndProgramData = surveyAndProgramData,
        spectrumFilesState = spectrumFilesState
    )
}