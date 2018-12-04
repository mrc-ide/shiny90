panelSpectrum <- function() {
    shiny::div("",
        shiny::tags$p("This app accepts .PJNZ files from Spectrum, but in the case where your .PJNZ file is very large,
        uploads may be very slow. In this case you can instead upload pairs of .DP and .PJN files extracted from the .PJNZ."),
        shiny::selectInput("spectrumFileType", label = "Use:", choices = c(".PJNZ", '.DP and .PJN')),
        shiny::tags$hr("", style="height: 1px;"),
        shiny::conditionalPanel(condition = "output.usePJNZ",
            shiny::div("Please upload either one national PJNZ file or multiple files, one per subnational region.",
                class = "mb-5"),
            shiny::div("", class = "mt-3 mb-5",
                shiny::fileInput("spectrumFile", "Choose PJNZ file(s)", accept = c(".pjnz"), multiple=TRUE),
                shiny::conditionalPanel(condition = "output.spectrumFileError != null",
                    shiny::div("", class = "alert alert-danger",
                        shiny::icon("exclamation-triangle", lib="font-awesome"),
                        shiny::span("Error: Spectrum file not valid!"),
                        shiny::textOutput("spectrumFileError", inline = TRUE)
                    )
                )
            )
        ),
        shiny::conditionalPanel(condition = "!output.usePJNZ",
            shiny::div("Please upload either one pair of PJ and DP files for the whole country, or multiple pairs of files,
            one pair per subnational region. You will have to upload regions one at a time.",
                class = "mb-5"),
                shiny::div("", class = "mt-3 mb-5",
                shiny::fileInput("spectrumFilePair", "Choose pair of PJN and DP files", accept = c(".dp", ".pjn"), multiple=TRUE),
                shiny::conditionalPanel(condition = "output.spectrumFilePairError != null",
                    shiny::div("", class = "alert alert-danger",
                        shiny::icon("exclamation-triangle", lib="font-awesome"),
                        shiny::span("Error: Spectrum file pair not valid!"),
                        shiny::textOutput("spectrumFilePairError", inline = TRUE)
                    )
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
                    shiny::span("data")
                ),

                shiny::tabsetPanel(
                shiny::tabPanel("Figures",
                    shiny::div("", class = "row",
                        shiny::div("", class = "col-md-6 col-sm-12",
                            shinycssloaders::withSpinner(plotOutput(outputId = "spectrumPrevalence"))),
                        shiny::div("", class = "col-md-6 col-sm-12",
                            shinycssloaders::withSpinner(plotOutput(outputId = "spectrumIncidence")))
                    ),
                    shiny::div("", class = "row",
                        shiny::div("", class = "col-md-6 col-sm-12",
                            shinycssloaders::withSpinner(plotOutput(outputId = "spectrumTotalPop"))),
                        shiny::div("", class = "col-md-6 col-sm-12",
                            shinycssloaders::withSpinner(plotOutput(outputId = "spectrumPLHIV")))
                    )
                ),
                    shiny::tabPanel("Data",
                        shiny::div("", class = "mt-3 spectrum-combined-data",
                            shiny::dataTableOutput("spectrum_combinedData")
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
