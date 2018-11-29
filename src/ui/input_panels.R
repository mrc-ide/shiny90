panelSurvey <- function() {
    shiny::div("",
        shiny::HTML("<p>Available survey data on the proportion of people ever tested by sex and age group are included below.
         You can edit the data in the browser, or copy and paste to Excel and edit the data there, then copy and paste back into the table below.
         You can also replace the data entirely by uploading a new CSV file. The required column headers are:</p>
         <p><strong>Survey Id, Country, Year, HIV Status, Sex, Age Group, Estimate, Standard Error,
        Lower Confidence Interval,
        Upper Confidence Interval, Counts</strong></p> <p>Estimates, Standard Error, and Lower and Upper Confidence Intervals
        should all be given as percentages.<p><p> The app will not accept an uploaded CSV with the wrong headers.
        It may be useful to download the existing survey data as a template:</p>"),
        shiny::downloadButton("downloadSurveyTemplate", "Download survey data"),
        shiny::h3("Upload new data"),
        errorAlert(id = "wrongSurveyHeadersError",
                    condition = "output.wrongSurveyHeaders",
                    message = "Error: Invalid headers! Survey data must match the given column headers. This file has been ignored."),
        errorAlert(id = "wrongSurveyCountryError",
                condition = "output.wrongSurveyCountry",
                message = "Error: You cannot upload survey data for a different country. This file has been ignored."),
        shiny::fileInput("surveyData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv")),
        shiny::h3("Or edit data in place",
        shiny::div(class="pull-right", actionButtonWithCustomClass("resetSurveyData", "Reset to built-in data", cssClasses ="btn-red"))),
        shiny::div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel. If you make a mistake, you can re-set to the built
        in data by clicking the button to the right.", class = "text-muted mb-1"),
        rhandsontable::rHandsontableOutput("hot_survey")
    )
}

panelProgram <- function() {
    shiny::div("",
        shiny::tags$p("The following is programmatic data sourced from national testing programs. Please review, update, and correct (if applicable)
        the programmatic data below that describes the annual number of HIV tests* performed at the national level among the population aged 15+
        years of age (and the number of positive tests)."),
        shiny::tags$ul(
        shiny::HTML("<li><strong>Total Tests:</strong> This is the annual number of tests performed at the national level among the population aged 15+ years of age.
                            This number should be equal to the total number of tests administered as part of HIV Testing and Counseling (HTC) and
                            during antenatal care (ANC), and for which the clients received the results.</li>"),
        shiny::HTML("<li><strong>Total Positive Tests:</strong> Out of the total annual number of tests, how many were found to be HIV positive.
                            This number should be equal to the number of positive tests found during HTC (in non-pregnant population) and during ANC among
                            pregnant women.</li>"),
        shiny::HTML("<li><strong>Total HTC Tests:</strong> Total annual number of tests performed in the population aged 15+ years outside of
                        ANC services,
                             and for which clients received the results. If only the overall total is available, please input NA.</li>"),
        shiny::HTML("<li><strong>Total HTC Positive Tests</strong>: Annual number of tests that were found to be positive for HIV outside of ANC services.</li>"),
        shiny::HTML("<li><strong>Total ANC Tests:</strong> Annual number of pregnant women tested for HIV (and that received their results) as part of ANC services.</li>"),
        shiny::HTML("<li><strong>Total ANC Positive Tests:</strong> Annual number of pregnant women found to be HIV positive during ANC services.</li>")
        ),
        shiny::p("*A person should only be counted as testing once even if up to three different assays are performed to confirm an HIV-positive diagnosis according to the national testing algorithm.
        A person who is tested twice during the year should be counted as contributing two tests."),
        shiny::tags$p("You can edit the data below in the browser, or copy and paste to Excel and edit the data there, then copy
                        and paste back into the table below. You can also replace the data entirely by uploading a new CSV file. The required column headers are:"),
        shiny::HTML("<p><strong>Country, Year, Total Tests, Total Positive Tests, Total HTC Tests, Total Positive HTC Tests, Total ANC Tests, Total Positive ANC Tests, Age Group, Sex, HIV Status</strong></p>"),
        shiny::p("The app will not accept an uploaded CSV with the wrong headers.
        It may be useful to download the existing programmatic data as a template:"),
        downloadButton("downloadProgramTemplate", "Download programmatic data"),
        shiny::h3("Upload new data"),
        errorAlert(id = "wrongProgramHeadersError", condition="output.wrongProgramHeaders",
                message = "Error: Invalid headers! Program data must match the given column headers. This file has been ignored."),
        errorAlert(condition="output.wrongProgramCountry", id="wrongProgramCountryError",
            message="Error: You cannot upload program data for a different country. This file has been ignored."),
        shiny::fileInput("programData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv")),
        shiny::h3("Or edit data in place"),
        shiny::div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel.", class = "text-muted mb-1"),
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
                shiny::div("The programmatic data for your country is incomplete. Please fill in missing values if you have them.",
                class = "mt-5 alert alert-warning", id="incomplete-warning")
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
