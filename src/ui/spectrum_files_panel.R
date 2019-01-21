panelSpectrum <- function() {
    shiny::div("",
        shiny::tags$p("This app accepts .PJNZ files from Spectrum, but in the case where your .PJNZ file is very large,
        uploads may be very slow. In this case you can instead upload pairs of .DP and .PJN files extracted from the .PJNZ."),
        shiny::selectInput("spectrumFileType", label = "Use:", choices = c(".PJNZ", '.DP and .PJN')),
        shiny::tags$hr("", style="height: 1px;"),
        shiny::conditionalPanel(condition = "output.usePJNZ",
            shiny::div("Please upload either one national or subnational PJNZ file or multiple files, one per subnational region.
            If you upload a single regional file we will use regional data and run everything at the regional level.
            If you include multiple regions we will use national data and run the model at a national level,
            so make sure you upload a complete covering set of subnational files.",
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
            shiny::div("Please upload either one pair of PJ and DP files for a single country or region, or multiple pairs of files,
            one pair per subnational region. You will have to upload regions one at a time. If you upload files for a single region we will use regional data and run everything at the regional level.
            If you include multiple regions we will use national data and run the model at a national level,
            so make sure you upload a complete covering set of subnational files.",
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
                shiny::h3("Uploaded Spectrum files", class = "mt-5"),
                shiny::tags$ul("", class = "list-group",
                    shiny::uiOutput("spectrumFileList")
                )
            ),

            shiny::div("",
                shiny::h3("", class = "mt-5",
                    shiny::textOutput("countryAndRegionName", inline = TRUE),
                    shiny::span("data")
                ),
                shiny::conditionalPanel(condition = "output.aggregatingToNational",
                    id="multiple-region-warning",
                    class="alert alert-warning",
                    "You have uploaded files for multiple regions
                     so we will run the model at national level. Please make sure you have included Spectrum data for
                      all subnational regions otherwise results will not be valid."
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
