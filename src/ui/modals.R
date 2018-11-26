loadDigestModal <- function() {
    modal(
        title = "Load digest file",
        id = "digestModal",
        cancelId = "cancelDigestUpload",
        shiny::fileInput("digestUpload", "Choose a Shiny 90 digest file", accept = ".zip.shiny90")
    )
}

editWorkingSetModal <- function() {
    modal(
        title = "Edit working set notes",
        id = "editWorkingSetModal",
        cancelId = "editWorkingSet_cancel_cross",
        shiny::tags$form("",
            inputBox("editWorkingSet_notes", "Notes", multiline = TRUE),
            shiny::fluidRow(
                div("", class = "col-md-6",
                    actionButtonWithCustomClass("editWorkingSet_cancel_button", "Cancel", cssClasses = "btn-red")
                ),
                div("", class = "col-md-6 text-right",
                    actionButtonWithCustomClass("editWorkingSet_update", "Update", cssClasses = "btn-red btn-success")
                )
            )
        )
    )
}