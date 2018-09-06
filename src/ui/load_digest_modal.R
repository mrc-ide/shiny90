library(shiny)

loadDigestModal <- function() {
    div("", class="modal",
        div("", class="modal-dialog",
            div("", class="modal-content",
                div("", class="modal-header",
                    div("", class="pull-right",
                        actionButtonWithCustomClass("cancelDigestUpload", "", cssClasses="close",
                            HTML("&times")
                        )
                    ),
                    div("Load digest file", class="modal-title")
                ),
                div("", class="modal-body",
                    fileInput("digestUpload", "Choose a Shiny 90 digest file", accept=".zip.shiny90")
                )
            )
        )
    )
}
