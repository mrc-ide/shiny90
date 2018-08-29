library(glue)

navigation_panel <- function() { div(class="col-md-3 col-lg-2 col-sm-12 sidebar nopadding",
        tags$ol(class="nav", `data-bind`="foreach: sections",
            tags$li(class="nav-item",
                a(class="nav-link", href="#", `data-bind`="text: $data.name, click: $parent.onClick, css: { active: $parent.currentSection().id() == $data }", "")
            )
        )
    )
}

content_panel <- function() {
    div(class="col-md-9",
        h1(`data-bind`="text: currentSection().name()"),
        panel_for("spectrum", panel_spectrum()),
        panel_for("survey", panel_survey()),
        panel_for("programmatic", panel_survey()),
        panel_for("review-input", panel_review_input()),
        panel_for("fit", panel_model_fit()),
        panel_for("run", panel_model_run())
    )
}

panel_for <- function(sectionID, content) {
    div(`data-bind`=glue("visible: currentSection().id() == '{sectionID}'"),
        content
    )
}
