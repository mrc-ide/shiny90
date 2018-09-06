library(shiny)
library(glue)
library(purrr)

digestButtons <- function() {
    div("", style="width: 64px; display: inline-block",
        a(id='digestDownload',
            class="btn btn-default shiny-download-link digest-button btn-sq btn-sq-sm btn-red text-center",
            href="",
            target="_blank",
            download=NA,
            img(id="digest-download-img", src="images/cloud-download-red.svg", width=32, height=32),
            tags$br(),
            tags$label(`for`="digest-download-img", "Save")
        ),
        actionButtonWithCustomClass("digestUpload", label="", cssClasses="digest-button btn-sq btn-sq-sm btn-red text-center",
            img(id="digest-upload-img", src="images/cloud-upload-red.svg", width=32, height=32),
            tags$br(),
            tags$label(`for`="digest-upload-img", "Load")
        )
    )
}

doAndRememberPath <- function(paths, path, func) {
    paths <- c(paths, path)
    func(path)
    paths
}

handleSaveAndLoad <- function(input, output, workingSet, spectrumFilesState, surveyAndProgramData) {
    output$digestDownload <- downloadHandler(
        filename = function() { glue("{workingSet$name}.zip") },
        contentType = "application/zip",
        content = function(file) {
            scratch <- tempfile()
            paths <- NULL
            dir.create(scratch)
            setwd(scratch)

            # Write out individual files
            paths <- doAndRememberPath(paths, "survey.csv", function(path) {
                write.csv(surveyAndProgramData$survey, file=path)
            })
            paths <- doAndRememberPath(paths, "program.csv", function(path) {
                write.csv(surveyAndProgramData$program, file=path)
            })
            if (!is.null(spectrumFilesState$combinedData())) {
                paths <- doAndRememberPath(paths, "combined_spectrum_data.rds", function(path) {
                    saveRDS(spectrumFilesState$combinedData(), file=path)
                })
            }

            # Create zip file
            print(paths)
            zip(file, paths)

            # Clean up
            unlink(scratch, recursive=TRUE)
        }
    )
}
