library(glue)

navigationPanel <- function() {
    navlistPanel(well=FALSE, widths=c(2, 10),
        panelWithTitle("Upload spectrum file(s)", panelSpectrum()),
        panelWithTitle("Upload survey data", panelSurvey()),
        panelWithTitle("Upload programmatic data", panelSurvey()),
        panelWithTitle("Review input data", panelReviewInput()),
        panelWithTitle("Fit model", panelModelFit()),
        panelWithTitle("Run model", panelModelRun())
    )
}

panelWithTitle <- function(title, content) {
    tabPanel(title, div("",
        h1(title),
        content
    ))
}
