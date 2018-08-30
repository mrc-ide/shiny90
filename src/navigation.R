navigationPanel <- function() {
    navlistPanel(well=FALSE, widths=c(3, 9),
        panelWithTitle("Upload spectrum file(s)", panelSpectrum()),
        panelWithTitle("Upload survey data", panelSurvey()),
        panelWithTitle("Upload programmatic data", panelProgram()),
        panelWithTitle("Review input data", panelReviewInput()),
        panelWithTitle("Run model", panelModelRun()),
        panelWithTitle("View model outputs", panelModelOutputs())
    )
}

panelWithTitle <- function(title, content) {
    tabPanel(title, div("",
        h1(title),
        content
    ))
}
