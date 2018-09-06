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
        cancelId="cancelEditingWorkingSet",
        tags$form("",
             inputBox("f1", "Name", type="text", value=""),
             inputBox("f2", "Notes", type="text", value=""),
             tags$button(class="btn btn-default btn-red", "Update")
        )
    )
}