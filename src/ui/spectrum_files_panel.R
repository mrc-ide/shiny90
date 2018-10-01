panelSpectrum <- function() {
    shiny::div("",
        shiny::div("Please upload either one national PJNZ file or multiple files, one per subnational region.",
            class = "mb-5"),
        shiny::div("", class = "mt-3 mb-5",
            shiny::fileInput("spectrumFile", "Choose PJNZ File", accept = c(".pjnz")),
            shiny::conditionalPanel(condition = "output.spectrumFileError != null",
                shiny::div("Spectrum file not valid!", class = "alert alert-warning",
                    shiny::textOutput("spectrumFileError", inline = TRUE)
                )
            )
        ),
        shiny::conditionalPanel(condition = "output.anySpectrumDataSets",
            shiny::div("", class = "mb-5 uploadedSpectrumFilesSection",
                shiny::h3("Uploaded PJNZ files", class = "mt-5"),
                shiny::tags$ul("", class = "list-group",
                    shiny::uiOutput("spectrumFileList")
                )
            ),

            shiny::div("",
                shiny::h3("", class = "mt-5",
                    shiny::textOutput("spectrumFilesCountry", inline = TRUE),
                    shiny::span("PJNZ data (combined)")
                ),

                shiny::tabsetPanel(
                    shiny::tabPanel("Figures", shinycssloaders::withSpinner(shiny::plotOutput(outputId = "spectrum_plots", height = "800px"))),
                    shiny::tabPanel("Data",
                        shiny::div("", class = "mt-3",
                            shiny::img(src = "images/mock-sheet.png")
                        )
                    )
                )
            )
        )
    )
}

# TODO table showing summary of combined data set (not per spectrum file):
# - Show pop, plhiv, prev, incidence, art coverage
# - Pick year from dropdown, default to most recent
