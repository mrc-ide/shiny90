panelSurvey <- function() {
    shiny::div("",
        shiny::div("The following is survey data sourced from DHS and PHIA. You can edit the data below in the browser, or copy and
             paste to Excel and edit the data there. You can also replace the data entirely be uploading a new CSV file
             below", class = "mb-3"),
        shiny::h3("Upload new data"),
        shiny::conditionalPanel(
        condition = "output.wrongSurveyHeaders",
            shiny::div("Invalid headers! Survey data must match the given column headers.", id="wrongSurveyHeadersError", class = "alert alert-warning")
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
        shiny::div("The following is programmatic data sourced from national testing programs.
             You can edit the data below in the browser, or copy and paste to Excel and edit the data there.
             You can also replace the data entirely be uploading a new CSV file below.",
            class = "mb-3"),
        shiny::h3("Upload new data"),
        shiny::conditionalPanel(
            condition = "output.wrongProgramHeaders",
            shiny::div("Invalid headers! Program data must match the given column headers.", id="wrongProgramHeadersError", class = "alert alert-warning")
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
