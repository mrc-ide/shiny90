library(shiny)

loadDigestModal <- function() {
    modal(
        title="Load digest file",
        cancelId="cancelDigestUpload",
        fileInput("digestUpload", "Choose a Shiny 90 digest file", accept=".zip.shiny90")
    )
}

editWorkingSetModal <- function() {
    modal(
        title="Edit working set",
        cancelId="editWorkingSet_cancel_cross",
        tags$form("",
            inputBox("editWorkingSet_name", "Name", type="text", value=""),
            inputBox("editWorkingSet_notes", "Notes", multiline=TRUE),
            fluidRow(
                div("", class="col-md-6",
                    actionButtonWithCustomClass("editWorkingSet_cancel_button", "Cancel", cssClasses="btn-red")
                ),
                div("", class="col-md-6 text-right",
                    actionButtonWithCustomClass("editWorkingSet_update", "Update", cssClasses="btn-red btn-success")
                )
            )
        )
    )
}