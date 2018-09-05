panelSpectrum <- function() {
    div("",
        div("Help text for this page: Cupcake ipsum dolor sit amet cotton candy soufflé topping. Icing dessert brownie jujubes lollipop topping. Cotton candy chocolate cake danish apple pie carrot cake wafer chocolate bar oat cake.",
            class="mb-3"),
        div("", class="mt-3 mb-5",
            fileInput("spectrumFile", "Choose PJNZ File", accept = c(".pjnz"))
        ),
        conditionalPanel(condition = "output.anySpectrumFiles",
            div("", class="mb-5",
                h3("Uploaded PJNZ files", class="mt-5"),
                tags$ul("", class="list-group",
                    uiOutput("spectrumFileList")
                )
            ),

            div("",
                h3("", class="mt-5",
                    textOutput("spectrumFilesCountry", inline=TRUE),
                    span("PJNZ data (combined)")
                ),

                tabsetPanel(
                    tabPanel("Figures",
                        fluidRow(
                            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "spectrum_hivPrevalance"))),
                            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "spectrum_hivIncidence")))
                        ),
                        fluidRow(
                            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "spectrum_populationSize"))),
                            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "spectrum_numberOfPeopleLivingWithHIV")))
                        )
                    ),
                    tabPanel("Data",
                        div("", class="mt-3",
                            dataTableOutput("spectrum_combinedData")
                        )
                    )
                )
            )
        )
    )
}

# Show country
# Summary of combined data set (not per spectrum file):
# Figures:
# - HIV prevalence
# - HIV incidence
# - Population size
# - Number of people living with HIV
# Table:
# - Show pop, plhiv, prev, incidence, art coverage
# - Pick year from dropdown, default to most recent
#
# Ability to see list of filenames uploaded
# Remove file uploaded by accident
