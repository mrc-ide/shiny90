panelSurvey <- function() {
    shiny::div("",
        shiny::div("The following is survey data sourced from DHS and PHIA. You can edit the data below in the browser, or copy and
             paste to Excel and edit the data there, then copy and paste back into the table below. You can also replace the data entirely
             by uploading a new CSV file.", class = "mb-3"),
        downloadButton("downloadSurveyTemplate", "Download survey data"),
        shiny::h3("Upload new data"),
        shiny::conditionalPanel(
        condition = "output.wrongSurveyHeaders",
            shiny::div("Invalid headers! Survey data must match the given column headers. If you are missing data points please just input NA.",
                        id="wrongSurveyHeadersError", class = "alert alert-warning")
        ),
        shiny::conditionalPanel(

        condition = "output.wrongSurveyCountry",
            shiny::div("You cannot upload survey data for a different country.", id="wrongSurveyCountryError", class = "alert alert-warning")
        ),
        shiny::fileInput("surveyData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv")),
        shiny::h3("Or edit data in place"),
        shiny::div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel.", class = "text-muted"),
        rhandsontable::rHandsontableOutput("hot_survey")
    )
}

panelProgram <- function() {
    shiny::div("",
        shiny::tags$p("The following is programmatic data sourced from national testing programs. Please review, update, and correct (if applicable)
        the programmatic data below that describes the annual number of HIV tests performed at the national level among the population aged 15+
        years of age (and the number of positive tests)."),
        shiny::tags$ul(
            shiny::HTML("<li><strong>Total tests:</strong> This is the annual number of tests performed at the national level among the population aged 15+ years of age.
                This number should be equal to the total number of tests administered as part of HIV Testing and Counseling (HTC) and
                during antenatal care (ANC), and for which the clients received the results.</li>"),
            shiny::HTML("<li><strong>Total positive tests:</strong> Out of the total annual number of tests, how many were found to be HIV positive.
                This number should be equal to the number of positive tests found during HTC (in non-pregnant population) and during ANC among
                pregnant women.</li>"),
            shiny::HTML("<li><strong>Total HTS tests:</strong> Total annual number of tests performed in the population aged 15+ years outside of ANC services,
                 and for which clients received the results. If only the overall total is available, please input NA.</li>"),
            shiny::HTML("<li><strong>Total HTS positive tests</strong>: Annual number of tests that were found to be positive for HIV outside of ANC services.</li>"),
            shiny::HTML("<li><strong>Total ANC tests:</strong> Annual number of pregnant women tested for HIV (and that received their results) as part of ANC services.</li>"),
            shiny::HTML("<li><strong>Total ANC positive tests:</strong> Annual number of pregnant women found to be HIV positive during ANC services.</li>")
        ),
        shiny::tags$p("You can edit the data below in the browser, or copy and paste to Excel and edit the data there, then copy
                        and paste back into the table below. You can also replace the data entirely by uploading a new CSV file.",
            class = "mb-3"),
        shiny::div("", class="mb-3 text-muted"),
        downloadButton("downloadProgramTemplate", "Download programmatic data"),
        shiny::h3("Upload new data"),
        shiny::conditionalPanel(
            condition = "output.wrongProgramHeaders",
            shiny::div("Invalid headers! Program data must match the given column headers. If you are missing data points please just input NA.",
            id="wrongProgramHeadersError", class = "alert alert-warning")
        ),
        shiny::conditionalPanel(
            condition = "output.wrongProgramCountry",
            shiny::div("You cannot upload program data for a different country.", id="wrongProgramCountryError", class = "alert alert-warning")
        ),
        shiny::fileInput("programData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv")),
        shiny::h3("Or edit data in place"),
        shiny::div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel.", class = "text-muted"),
        rhandsontable::rHandsontableOutput("hot_program")
    )
    # TODO: Should always have (blank rows if no data) years from 2005 - current year
}


panelReviewInput <- function() {
    shiny::div("",
        shiny::div("Here's a visualisation of the data you have uploaded so far.
            Please review it, and go back and edit your data if anything doesn't look right.",
            class = "mb-3"
        ),
        shiny::div("", class="suggest-save",
            shiny::span("Once you have reviewed your input data, you may want to "),
            shiny::tags$a(class = "shiny-download-link", href = "", "download a digest file", id = "digestDownload3", download = NA, target = "_blank"),
            shiny::span("containing your input data and results. You can re-upload this file later to view your results again and change your input data.")
        ),
        shiny::conditionalPanel(
            condition = "output.incompleteProgramData",
                shiny::div("The programmatic data for your country is incomplete. Please fill in missing values if you have them.", class = "mt-5 alert alert-warning")
        ),
        shiny::div("", class = "row",
            shiny::conditionalPanel(
                condition = "output.anyProgramDataTot",
                    shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "reviewTotalTests")))
            ),
            shiny::conditionalPanel(
                condition = "output.anyProgramDataTotPos",
                    shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "reviewTotalPositive")))
            )
        ),
        shiny::div("", class = "row",
            shiny::conditionalPanel(
                condition = "output.anyProgramDataAnc",
                    shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "reviewTotalANC")))
            ),
            shiny::conditionalPanel(
                condition = "output.anyProgramDataAncPos",
                    shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "reviewTotalANCPositive")))
            )
        ),
        shiny::div("", class = "row",
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "reviewPrevalence"))),
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "reviewIncidence")))
        ),
        shiny::div("", class = "row",
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "reviewTotalPop"))),
            shiny::div("", class = "col-md-6 col-sm-12", shinycssloaders::withSpinner(plotOutput(outputId = "reviewPLHIV")))
        )
    )
    # TODO: More plots when Jeff knows what's needed
}
