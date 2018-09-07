library(shiny)
library(rhandsontable)
library(shinycssloaders)

panelSurvey <- function() {
    div("",
        div("The following is survey data sourced from ??. You can edit the data below in the browser, or copy and
             paste to Excel and edit the data there. You can also replace the data entirely be uploading a new CSV file
             below", class = "mb-3"),
        h3("Edit data in place"),
        div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel.", class = "text-muted"),
        rHandsontableOutput("hot_survey"),
        h3("Or upload new data"),
        fileInput("surveyData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv"))
    )
}

panelProgram <- function() {
    div("",
        div("The following is programmatic data sourced from ??. You can edit the data below in the browser, or copy and
             paste to Excel and edit the data there. You can also replace the data entirely be uploading a new CSV file
             below",
            class = "mb-3"),
        h3("Edit data in place"),
        div("Hint: Select rows and use ctrl-c to copy to clipboard. Use ctrl-v to paste rows from excel.", class = "text-muted"),
        rHandsontableOutput("hot_program"),
        h3("Or upload new data"),
        fileInput("programData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv"))
    )
}

panelReviewInput <- function() {
    div("",
        div("Here's a visualisation of the data you have uploaded so far.
            Please review it, and go back and edit your data if anything doesn't look right.",
            class = "mb-3"
        ),
        div("",
            span("Once you have reviewed your input data, you may want to "),
            tags$a(href = "#", "download a digest file"),
            span("containing your input data and results. You can re-upload this file later to view your results again and change your input data.")
        ),
        withSpinner(plotOutput(outputId = "inputReview", height = "800px"))
    )

    # ✓ Number tested (as a proportion of the population? / in 1000s?)
    # ✓ Number of positive tests (in 1000s)
    # Still needs:
    # Number tested at ante-natal care (ANC, in 1000s)
    # Number tested positive at ante-natal care (in 1000s)
}
