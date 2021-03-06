panelSurvey <- function() {
    shiny::div("",
        shiny::tags$p("Please provide survey data on the proportion of people ever tested by sex and age group, and HIV serostatus (if available).
                      Where available please provide the following:"),
        shiny::tags$ul(
            shiny::HTML("<li><strong>Country or region:</strong> Must exactly match country or region in top left panel.</li>"),
            shiny::HTML("<li><strong>Survey Id:</strong> Provide a unique identifier for your survey (each survey must have a unique name).</li>"),
            shiny::HTML("<li><strong>Year:</strong> Year in which survey was conducted; year of survey fieldwork
                        midpoint if survey spanned multiple years.</li>"),
            shiny::HTML("<li><strong>Age Group:</strong> 15-24, 25-34, 35-49, 50+, 15-49 or 15+.</li>"),
            shiny::HTML("<li><strong>Sex</strong> \"male\", \"female\" or \"both\".</li>"),
            shiny::HTML("<li><strong>HIV Status:</strong> \"positive\", \"negative\" or \"all\".</li>"),
            shiny::HTML("<li><strong>Estimate:</strong> Estimate for proportion ever tested for HIV; as a percentage (e.g. 87.6 rather than proportion 0.876).</li>"),
            shiny::HTML("<li><strong>Standard Error:</strong> Standard Error of the estimate (as a percentage). Should take into account survey design effects.</li>"),
            shiny::HTML("<li><strong>Lower Confidence Interval:</strong> Lower limit of the 95% confidence interval of the survey estimate  (as a percentage).</li>"),
            shiny::HTML("<li><strong>Upper Confidence Interval:</strong>  Upper limit of the 95% confidence interval of the survey estimate (as a percentage).</li>"),
            shiny::HTML("<li><strong>Counts:</strong> Unweighted counts of the number of survey respondents included in the stratification group.</li>")
        ),
        shiny::tags$p("You can copy and paste from Excel or upload a new CSV file."),
        shiny::tags$p("All columns are required. Where values are unknown, please just leave blank. 
                      The app will not accept an uploaded CSV with the wrong headers. It may be
                      useful to download the headers as a template:"),
        shiny::downloadButton("downloadSurveyTemplate", "Download CSV template", class = "mb-4"),
        infoAlert("usePercentInfo", "Estimates, Standard Error and Lower and Upper Confidence Intervals should
                  all be given as percentages (for example, enter percentage 87.56 rather than proportion 0.8756)."),
        shiny::h3("Upload new data"),
        errorAlert(id = "wrongSurveyHeadersError",
                    condition = "output.wrongSurveyHeaders",
                    message = "Error: Invalid headers! Survey data must match the given column headers. This file has been ignored."),
        errorAlert(id = "wrongSurveyCountryError",
                condition = "output.wrongSurveyCountry",
                message = "Error: You cannot upload survey data for a different country. This file has been ignored."),
        shiny::fileInput("surveyData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv")),
        shiny::h3("Or edit data in place"),
        shiny::div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel.", class = "text-muted mb-1"),
        rhandsontable::rHandsontableOutput("hot_survey")
    )
}

panelProgram <- function() {
    shiny::div("", class="mb-3",
        shiny::tags$p("Please provide programmatic data sourced from national testing programs. For each year please
        provide either sex aggregated data (1 row with sex = \"both\") or sex disaggregated data (2 rows with sex=\"male\" and sex=\"female\" respectively).
        Where values are unknown, please just leave blank.
        Where available please provide
        the following:"),
        shiny::tags$ul(
        shiny::HTML("<li><strong>Country or region:</strong> Must exactly match country or region in top left panel.</li>"),
        shiny::HTML("<li><strong>Year:</strong> Calendar year in which the HIV tests were performed.</li>"),
        shiny::HTML("<li><strong>Total Tests:</strong> This is the annual number of tests performed at the national level among the population aged 15+ years of age.
                            This number should be equal to the total number of tests administered as part of HIV Testing and Counseling (HTC) and
                            during antenatal care (ANC), and for which the clients received the results.</li>"),
        shiny::HTML("<li><strong>Total Positive Tests:</strong> Out of the total annual number of tests, how many were found to be HIV positive.
                            This number should be equal to the number of positive tests found during HTC (in non-pregnant population) and during ANC among
                            pregnant women.</li>"),
        shiny::HTML("<li><strong>Total HTC Tests:</strong> Total annual number of tests performed in the population aged 15+ years outside of
                        ANC services,
                             and for which clients received the results.</li>"),
        shiny::HTML("<li><strong>Total Positive HTC Tests</strong>: Annual number of tests that were found to be positive for HIV outside of ANC services.</li>"),
        shiny::HTML("<li><strong>Total ANC Tests:</strong> Annual number of pregnant women tested for HIV (and that received their results) as part of ANC services.</li>"),
        shiny::HTML("<li><strong>Total Positive ANC Tests:</strong> Annual number of pregnant women found to be HIV positive during ANC services.</li>"),
        shiny::HTML("<li><strong>Sex:</strong> Male, female or both.</li>")
        ),
        shiny::p("*A person should only be counted as testing once even if up to three different assays are performed to confirm an HIV-positive diagnosis according to the national testing algorithm.
        A person who is tested twice during the year should be counted as contributing two tests."),
        shiny::tags$p("You can copy and paste data from Excel into the table below or upload a CSV file."),
        shiny::p("All columns are required. Where values are unknown, please just leave blank. The app will 
        not accept an uploaded CSV with the wrong headers. It may be useful to download the headers as a template:"),
        downloadButton("downloadProgramTemplate", "Download CSV template"),
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
}


panelReviewInput <- function() {
    shiny::div("",
        shiny::div("Here's a visualisation of the data you have uploaded so far.
            Please review it, and go back and edit your data if anything doesn't look right.",
            class = "mb-3"
        ),
        shiny::div("", class="suggest-save mb-3",
            shiny::span("Please save your work. This downloads a file containing your input data and results. 
                        If you get disconnected from the server, or if you want to return to the app later 
                        and review your results, you can re-upload this file and resume where you left off.")
        ),
        shiny::div("", class="save-button",
            downloadButtonWithCustomClass("digestDownload3", "Save your work", 
                                          font_awesome_icon = "download")
        ),
        shiny::conditionalPanel(
            condition = "output.invalidProgramData",
            shiny::div("The programmatic data for your country is invalid. Please check the guidance and correct it.",
            class = "mt-5 alert alert-danger", id="invalid-error")
        ),
        shiny::conditionalPanel(
          condition = "output.invalidSurveyData",
          shiny::div("The survey data for your country is invalid. Please check the guidance and correct it.",
                     class = "mt-5 alert alert-danger", id="invalid-error")
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
