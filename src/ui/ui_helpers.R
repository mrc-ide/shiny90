inputBox <- function(id, label, explanation = "", type = "number", value = 0, multiline = FALSE) {
    classes <- "form-control shiny-bound-input"
    if (multiline) {
        control <- shiny::tags$textarea(id = id, class = classes, rows = 10)
    } else {
        control <- shiny::tags$input(id = id, type = type, value = value, class = classes)
    }

    div("", class = "form-group",
        shiny::tags$label(`for`=id,
            shiny::tags$strong(label),
            shiny::HTML("&nbsp;&nbsp;"),
            shiny::span(explanation, style = "font-weight: normal")
        ),
        control
    )
}

actionButtonWithCustomClass <- function (inputId, label, ..., cssClasses = NULL, type = "button") {
    value <- shiny::restoreInput(id = inputId, default = NULL)
    shiny::tags$button(id = inputId, type = type,
        class = paste("btn btn-default action-button ", cssClasses), `data-val` = value,
        list(label), ...)
}

modal <- function(title, cancelId, ...) {
    div("", class = "modal",
        div("", class = "modal-dialog",
            div("", class = "modal-content",
                div("", class = "modal-header",
                    div("", class = "pull-right",
                        actionButtonWithCustomClass(cancelId, "", cssClasses = "close", HTML("&times"))
                    ),
                    div(title, class = "modal-title")
                ),
                div("", class = "modal-body",
                    ...
                )
            )
        )
    )
}