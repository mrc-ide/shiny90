library(shiny)

loadDigestModal <- function() {
    modal(
        title="Load digest file",
        cancelId="cancelDigestUpload",
        fileInput("digestUpload", "Choose a Shiny 90 digest file", accept=".zip.shiny90")
    )
}
