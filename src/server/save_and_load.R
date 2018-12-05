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
            write.csv(surveyAndProgramData$survey_data_human_readable(), file = path, row.names = FALSE, na = "")
        })
        paths <- doAndRememberPath(paths, "program.csv", function(path) {
            write.csv(surveyAndProgramData$program_data_human_readable(), file = path, row.names = FALSE, na = "")
        })
    }
    if (!is.null(modelRunState$optim)) {
        dir.create("model_outputs")
        paths <- doAndRememberPath(paths, file.path("model_outputs", glue::glue("par.rds")), function(path) {
            saveRDS(modelRunState$optim$par, file = path)
        })
        if (!is.null(modelRunState$spectrum_outputs)) {
            paths <- doAndRememberPath(paths, file.path("model_outputs", glue::glue("spectrum_output.csv")), function(path) {
                write.csv(modelRunState$spectrum_outputs, file = path, row.names = FALSE)
            })
        }
        if (!is.null(modelRunState$sample)) {
            paths <- doAndRememberPath(paths, file.path("model_outputs", glue::glue("sample.rds")), function(path) {
                saveRDS(modelRunState$sample, file = path)
            })

            paths <- doAndRememberPath(paths, file.path("model_outputs", glue::glue("hessian.rds")), function(path) {
                saveRDS(modelRunState$optim$hessian, file = path)
            })
        }
    }

    paths <- doAndRememberPath(paths, "README.md", function(path) {
        content <- readmeTemplate
        content <- gsub("__COUNTRY__", workingSet$name(), content)
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
        filename = function() { glue::glue("{workingSet$name()}.zip.shiny90") },
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

readCSVIfPresent <- function(fileName, headers) {
    if (file.exists(fileName)) {
        mapHeadersFromHumanReadable(read.csv(fileName, check.names=FALSE, na.strings=c("NA","NaN", " ")), headers)

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
            withDir(scratch, {
                spectrumFilesState$country <- readCountry()
                workingSet$notes <- file.readText("notes.txt")
                workingSet$selected <- TRUE
                surveyAndProgramData$survey <- readCSVIfPresent("survey.csv", c(surveyDataHeaders, sharedHeaders))
                surveyAndProgramData$program_data <- readCSVIfPresent("program.csv", c(programDataHeaders, sharedHeaders))
                spectrumFilesState$dataSets <- purrr::map(list.files("spectrum_data"), function(path) {
                    list(
                        name = removeExtension(path, "rds"),
                        data = readRDS(file.path("spectrum_data", path))
                    )
                })

                modelRunState$optim <- NULL
                modelRunState$simul <- NULL
                modelRunState$state <- "not_run"

                outputsPath <- "model_outputs/par.rds"
                if (file.exists(outputsPath)) {
                    modelRunState$optim <- list(par=readRDS(outputsPath))
                    hessianPath <- "model_outputs/hessian.rds"
                    if (file.exists(hessianPath)) {
                        modelRunState$optim$hessian<- readRDS(hessianPath)
                    }
                    samplePath <- "model_outputs/sample.rds"
                    if (file.exists(samplePath)) {
                        modelRunState$sample <- readRDS(samplePath)
                        shiny::withProgress(message = 'Running simulations', value = 0, {
                            shiny::incProgress(1/10)
                            simul <- first90::simul.run(modelRunState$sample, spectrumFilesState$combinedData(),
                                                        progress=makeProgress(nrow(modelRunState$sample)))
                            modelRunState$simul <- simul
                        })
                    }
                    modelRunState$state <- "converged"
                }

                surveyAndProgramData$touched <- FALSE
                spectrumFilesState$touched <- FALSE
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