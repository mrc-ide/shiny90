library(glue)

navigation_panel <- function() {
    navlistPanel(well=FALSE, widths=c(2, 10),
        panel_with_title("Upload spectrum file", panel_spectrum()),
        panel_with_title("Upload survey data", panel_survey()),
        panel_with_title("Upload programmatic data", panel_survey()),
        panel_with_title("Review input data", panel_review_input()),
        panel_with_title("Fit model", panel_model_fit()),
        panel_with_title("Run model", panel_model_run())
    )
}

panel_with_title <- function(title, content) {
    tabPanel(title, div("",
        h1(title),
        content
    ))
}
