edit_link <- function(id) {
    shiny::a("Edit", href = "#", title = "Edit", id = id, class = "action-button shiny-bound-input",
        shiny::icon("pencil", lib = "glyphicon")
    )
}
