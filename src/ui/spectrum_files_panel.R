library(shiny)
library(shinycssloaders)

panelSpectrum <- function() {
    div("",
        div("Please upload either one national PJNZ file or multiple files, one per subnational region.",
            class = "mb-5"),
        div("", class = "mt-3 mb-5",
            fileInput("spectrumFile", "Choose PJNZ File", accept = c(".pjnz"))
        ),
        conditionalPanel(condition = "output.anySpectrumDataSets",
            div("", class = "mb-5",
                h3("Uploaded PJNZ files", class = "mt-5"),
                tags$ul("", class = "list-group",
                    uiOutput("spectrumFileList")
                )
            ),

            div("",
                h3("", class = "mt-5",
                    textOutput("spectrumFilesCountry", inline = TRUE),
                    span("PJNZ data (combined)")
                ),

                tabsetPanel(
                    tabPanel("Figures", withSpinner(plotOutput(outputId = "spectrum_plots", height = "800px"))),
                    tabPanel("Data",
                        div("", class = "mt-3",
                            img(src = "images/mock-sheet.png")
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
