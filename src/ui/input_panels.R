panelSurvey <- function() {
    shiny::div("",
        shiny::div("The following is survey data sourced from DHS and PHIA. You can edit the data below in the browser, or copy and
             paste to Excel and edit the data there. You can also replace the data entirely be uploading a new CSV file
             below", class = "mb-3"),
        shiny::h3("Edit data in place"),
        shiny::div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel.", class = "text-muted"),
        rhandsontable::rHandsontableOutput("hot_survey"),
        shiny::h3("Or upload new data"),
        shiny::conditionalPanel(
        condition = "output.wrongSurveyHeaders",
            shiny::div("Invalid headers! Survey data must match the given column headers.", id="wrongSurveyHeadersError", class = "alert alert-warning")
        ),
        shiny::conditionalPanel(
        condition = "output.wrongSurveyCountry",
            shiny::div("You cannot upload survey data for a different country.", id="wrongSurveyCountryError", class = "alert alert-warning")
        ),
        shiny::fileInput("surveyData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv"))
    )
}

panelProgram <- function() {
    shiny::div("",
        shiny::div("The following is programmatic data sourced from national testing programs.
             You can edit the data below in the browser, or copy and paste to Excel and edit the data there.
             You can also replace the data entirely be uploading a new CSV file below.",
            class = "mb-3"),
        shiny::conditionalPanel(
            condition = "output.noProgramData",
            shiny::div("Warning: we have no program data for your country! You must add some data to proceed.", class = "alert alert-warning")
            # TODO: link to help email? Include specific instructions about what data are needed?
        ),
        shiny::h3("Upload new data"),
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
        shinycssloaders::withSpinner(shiny::plotOutput(outputId = "inputReview", height = "800px"))
    )
    # TODO: More plots when Jeff knows what's needed
}
