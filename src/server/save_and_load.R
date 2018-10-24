doAndRememberPath <- function(paths, path, func) {
    paths <- c(paths, path)
    func(path)
    paths
}

removeExtension <- function(path, extension) {
    regexp <- glue::glue(".{extension}$")
    gsub(regexp, "", path)
}

writeFilesForDigest <- function(workingSet, spectrumFilesState, surveyAndProgramData, modelRunState, readmeTemplate) {
    paths <- NULL
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
    if (spectrumFilesState$anyDataSets()) {
        paths <- doAndRememberPath(paths, "country.txt", function(path) {
            file.writeText(path, spectrumFilesState$country)
        })
        paths <- doAndRememberPath(paths, "survey.csv", function(path) {
            write.csv(surveyAndProgramData$survey, file = path, row.names = FALSE)
        })
        paths <- doAndRememberPath(paths, "program.csv", function(path) {
            write.csv(surveyAndProgramData$program_data, file = path, row.names = FALSE)
        })
    }
    if (!is.null(modelRunState$optim)) {
        dir.create("model_outputs")
        paths <- doAndRememberPath(paths, file.path("model_outputs", glue::glue("optim.rds")), function(path) {
            saveRDS(modelRunState$optim, file = path)
        })
        if (!is.null(modelRunState$simul)) {
            paths <- doAndRememberPath(paths, file.path("model_outputs", glue::glue("simul.rds")), function(path) {
                saveRDS(modelRunState$simul, file = path)
            })
        }
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

downloadDigest <- function(workingSet, spectrumFilesState, surveyAndProgramData, modelRunState) {

    shiny::downloadHandler(
        filename = function() { glue::glue("{workingSet$name}.zip.shiny90") },
        contentType = "application/zip",
        content = function(file) {
            readmeTemplate <- file.readText("template_for_digest_readme.md")
            scratch <- tempfile()
            dir.create(scratch)
            withDir(scratch, {
                paths <- writeFilesForDigest(workingSet, spectrumFilesState,
                                             surveyAndProgramData, modelRunState, readmeTemplate)
                zip(file, paths)
            })
            unlink(scratch, recursive = TRUE)
        }
    )
}

handleSave <- function(output, workingSet, spectrumFilesState, surveyAndProgramData, modelRunState) {
    output$digestDownload1 <- downloadDigest(workingSet, spectrumFilesState, surveyAndProgramData, modelRunState)
    output$digestDownload2 <- downloadDigest(workingSet, spectrumFilesState, surveyAndProgramData, modelRunState)
    output$digestDownload3 <- downloadDigest(workingSet, spectrumFilesState, surveyAndProgramData, modelRunState)
}

readCountry <- function() {
    if (file.exists("country.txt")) {
        gsub("[\r\n]", "", file.readText("country.txt"))
    } else {
        NULL
    }
}

readCSVIfPresent <- function(fileName) {
    if (file.exists(fileName)) {
        read.csv(fileName)
    } else {
        NULL
    }
}

handleLoad <- function(input, workingSet, surveyAndProgramData, spectrumFilesState, modelRunState) {
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
                spectrumFilesState$country <- readCountry()
                workingSet$notes <- file.readText("notes.txt")
                surveyAndProgramData$survey <- readCSVIfPresent("survey.csv")
                surveyAndProgramData$program_data <- readCSVIfPresent("program.csv")
                spectrumFilesState$dataSets <- purrr::map(list.files("spectrum_data"), function(path) {
                    list(
                        name = removeExtension(path, "rds"),
                        data = readRDS(file.path("spectrum_data", path))
                    )
                })
                outputsPath <- "model_outputs/optim.rds"
                if (file.exists(outputsPath)) {
                    modelRunState$optim <- readRDS(outputsPath)
                    simulPath <- "model_outputs/simul.rds"
                    if (file.exists(simulPath)) {
                        modelRunState$simul <- readRDS(simulPath)
                    }
                } else {
                    modelRunState$optim <- NULL
                    modelRunState$state <- "not_run"
                }
            })

            surveyAndProgramData$loadNewData <- FALSE
        }
    })

    list(
        state = state,
        workingSet = workingSet,
        surveyAndProgramData = surveyAndProgramData,
        spectrumFilesState = spectrumFilesState,
        modelRunState = modelRunState
    )
}