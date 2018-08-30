panelSpectrum <- function() {
    div("",
        div("Help text for this page: Cupcake ipsum dolor sit amet cotton candy soufflé topping. Icing dessert brownie jujubes lollipop topping. Cotton candy chocolate cake danish apple pie carrot cake wafer chocolate bar oat cake.",
        class="mb-3"),
        fileInput("spectrumFile", "Choose PJNZ File", accept = c(".pjnz"))
    )
}

panelSurvey <- function() {
    div("",
        div("Help text for this page: Cupcake ipsum dolor sit amet cotton candy soufflé topping. Icing dessert brownie jujubes lollipop topping. Cotton candy chocolate cake danish apple pie carrot cake wafer chocolate bar oat cake.",
        class="mb-3"),
        h3("Edit data in place"),
        img(src="images/mock-sheet.png"),
        h3("Or upload new data"),
        fileInput("surveyData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv"))
    )
}

panelReviewInput <- function() {
    div("",
        div("Here's a visualisation of the data you have uploaded so far.
            Please review it, and go back and edit your data if anything doesn't look right.",
            class="mb-3"
        ),
        div("", class="row",
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "inputReview_totalNumberOfTests"))),
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "inputReview_numberOfPositiveTests")))
        ),
        div("", class="row",
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "inputReview_percentageNegativeOfTested"))),
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "inputReview_percentagePLHIVOfTested")))
        ),
        div("", class="row",
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "inputReview_percentageTested"))),
            div("", class="col-md-6 col-sm-12", withSpinner(plotOutput(outputId = "inputReview_firstAndSecond90")))
        )
    )
}
