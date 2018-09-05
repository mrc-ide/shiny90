panelSpectrum <- function() {
    div("",
        div("Help text for this page: Cupcake ipsum dolor sit amet cotton candy soufflé topping. Icing dessert brownie jujubes lollipop topping. Cotton candy chocolate cake danish apple pie carrot cake wafer chocolate bar oat cake.",
        class="mb-3"),
        fileInput("spectrumFile", "Choose PJNZ File", accept = c(".pjnz")),
        conditionalPanel(
            condition = "output.anySpectrumFiles",
            h3("Uploaded PJNZ files"),
            tags$ul(
                uiOutput("spectrumFileList")
            ),

            h3("",
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
    )
}

panelSurvey <- function() {
    div("",
        div("Help text for this page: Cupcake ipsum dolor sit amet cotton candy soufflé topping. Icing dessert brownie jujubes lollipop topping. Cotton candy chocolate cake danish apple pie carrot cake wafer chocolate bar oat cake.",
        class="mb-3"),
        h3("Edit data in place"),
        div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel.", class="text-muted"),
        rHandsontableOutput("hot_survey"),
        h3("Or upload new data"),
        fileInput("surveyData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv"))
    )
}

panelProgram <- function() {
    div("",
    div("Help text for this page: Cupcake ipsum dolor sit amet cotton candy soufflé topping. Icing dessert brownie jujubes lollipop topping. Cotton candy chocolate cake danish apple pie carrot cake wafer chocolate bar oat cake.",
    class="mb-3"),
    h3("Edit data in place"),
    div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel.", class="text-muted"),
    rHandsontableOutput("hot_program"),
    h3("Or upload new data"),
    fileInput("programData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv"))
    )
}

panelReviewInput <- function() {
    div("",
        div("Here's a visualisation of the data you have uploaded so far.
            Please review it, and go back and edit your data if anything doesn't look right.",
            class="mb-3"
        ),
        div("",
            span("Once you have reviewed your input data, you may want to "),
            tags$a(href="#", "download a digest file"),
            span("containing your input data and results. You can re-upload this file later to view your results again and change your input data.")
        ),
        div("", class="row",
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "inputReview_a"))),
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "inputReview_b")))
        )
    )

    # Number tested (as a proportion of the population? / in 1000s?)
    # Number of positive tests (in 1000s)
    # Number tested at ante-natal care (ANC, in 1000s)
    # Number tested positive at ante-natal care (in 1000s)
}
