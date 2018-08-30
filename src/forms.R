inputBox <- function(id, label, explanation, type="number", value=0) {
    div("", class="form-group",
        tags$label(`for`=id,
            tags$strong(label),
            HTML("&nbsp;&nbsp;"),
            span(explanation, style="font-weight: normal")
        ),
        tags$input(id=id, type=type, value=value, class="form-control shiny-bound-input")
    )
}
