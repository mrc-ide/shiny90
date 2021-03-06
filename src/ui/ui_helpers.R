inputBox <- function(id, label, explanation = "", type = "number", value = 0, multiline = FALSE) {
    classes <- "form-control shiny-bound-input"
    if (multiline) {
        control <- shiny::tags$textarea(id = id, class = classes, rows = 10)
    } else {
        control <- shiny::tags$input(id = id, type = type, value = value, class = classes)
    }

    shiny::div("", class = "form-group",
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

downloadButtonWithCustomClass <- function (inputId, label, ..., cssClasses = NULL, type = "button", emphasis = "high", font_awesome_icon = NULL) {
  if (emphasis == "high") {
    classes <- paste("btn btn-default btn-red btn-lg btn-success shiny-download-link", cssClasses)
  } else if (emphasis == "medium") {
    classes <- paste("btn btn-default shiny-download-link", cssClasses)
  } else {
    classes <- cssClasses
  }
  value <- shiny::restoreInput(id = inputId, default = NULL)
  icon <- shiny::icon(font_awesome_icon)
  shiny::tags$a(id = inputId, icon, label, href = "", class = classes, 
                download = NA, target = "_blank", ...)
}

modal <- function(title, id, cancelId, ...) {
    shiny::div("", class = "modal", id = id,
        shiny::div("", class = "modal-dialog",
            shiny::div("", class = "modal-content",
                shiny::div("", class = "modal-header",
                    shiny::div("", class = "pull-right",
                        actionButtonWithCustomClass(cancelId, "", cssClasses = "close", shiny::HTML("&times"))
                    ),
                    shiny::div(title, class = "modal-title")
                ),
                shiny::div("", class = "modal-body",
                    ...
                )
            )
        )
    )
}

errorAlert <- function(condition, id, message){
    shiny::conditionalPanel(
        condition = condition,
            shiny::div("", id=id, class = "alert alert-danger",
            shiny::icon("exclamation-triangle", lib="font-awesome"),
            shiny::span(message)
        )
    )
}

infoAlert <- function(id, message){
    shiny::div("", id=id, class = "alert alert-info",
        shiny::icon("info-circle", lib="font-awesome"),
        shiny::span(message)
    )
}