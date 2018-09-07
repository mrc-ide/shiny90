library(shiny)

inputBox <- function(id, label, explanation="", type="number", value=0, multiline=FALSE) {
    classes <- "form-control shiny-bound-input"
    if (multiline) {
        control <- tags$textarea(id=id, class=classes, rows=10)
    } else {
        control <- tags$input(id=id, type=type, value=value, class=classes)
    }

    div("", class="form-group",
        tags$label(`for`=id,
            tags$strong(label),
            HTML("&nbsp;&nbsp;"),
            span(explanation, style="font-weight: normal")
        ),
        control
    )
}

actionButtonWithCustomClass <- function (inputId, label, cssClasses = NULL, ...) {
    value <- restoreInput(id = inputId, default = NULL)
    tags$button(id = inputId, type = "button",
        class = paste("btn btn-default action-button ", cssClasses), `data-val` = value,
        list(label), ...)
}

modal <- function(title, cancelId, ...) {
    div("", class="modal",
        div("", class="modal-dialog",
            div("", class="modal-content",
                div("", class="modal-header",
                    div("", class="pull-right",
                        actionButtonWithCustomClass(cancelId, "", cssClasses="close", HTML("&times"))
                    ),
                    div(title, class="modal-title")
                ),
                div("", class="modal-body",
                    ...
                )
            )
        )
    )
}