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
        panel_for("fit", panel_fit()),
        panel_for("run", panel_run())
    )
}

panel_for <- function(sectionID, content) {
    div(`data-bind`=glue("visible: currentSection().id() == '{sectionID}'"),
        content
    )
}

panel_spectrum <- function() {
    div("",
        div("Help text for this page: Cupcake ipsum dolor sit amet cotton candy soufflé topping. Icing dessert brownie jujubes lollipop topping. Cotton candy chocolate cake danish apple pie carrot cake wafer chocolate bar oat cake.",
            class="mb-3"),
        fileInput("spectrumFile", "Choose PJNZ File", accept = c(".pjnz"))
    )
}

panel_survey <- function() {
    div("",
        div("Help text for this page: Cupcake ipsum dolor sit amet cotton candy soufflé topping. Icing dessert brownie jujubes lollipop topping. Cotton candy chocolate cake danish apple pie carrot cake wafer chocolate bar oat cake.",
            class="mb-3"),
        h3("Edit data in place"),
        img(src="mock-sheet.png"),
        h3("Or upload new data"),
        fileInput("surveyData", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain",".csv"))
    )
}

panel_review_input <- function() {
    div("",
        div("Here's a visualisation of the data you have uploaded so far.
             Please review it, and go back and edit your data if anything doesn't look right",
             class="mb-3")
    )
}

panel_fit <- function() {
    div("",
        tags$button("Begin model fitting"),
        div("This make take several minutes. Please do not close your browser.", class="mt-3")
    )
}

panel_run <- function() {
    div("",
        h3("Enter model parameters"),
        inputBox("parameter2", "Z", "Number of iterations", value = "500"),
        inputBox("parameter1", "X", "Sincerity", value = "5"),
        inputBox("parameter3", "A", "Enthusiam", value = "0.23"),
        inputBox("parameter4", "N2", "Proportion that Jeff makes up", value = "8"),
        tags$button("Run model")
    )
}

inputBox <- function(id, label, explanation, type="number", value=0) {
    div("", class="form-group",
        tags$label(`for`=id,
            tags$strong(label),
            HTML("&nbsp;&nbsp;"),
            span(explanation, style="font-weight: normal")
        ),
        tags$input(id=id, type=type, value=value, class="form-control")
    )
}
