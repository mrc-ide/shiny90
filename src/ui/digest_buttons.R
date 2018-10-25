digestButtons <- function() {
    shiny::div("", style = "width: 64px; display: inline-block",
        shiny::a(id='digestDownload1',
            class = "btn btn-default shiny-download-link digest-button btn-sq btn-sq-sm btn-red text-center",
            href = "",
            target = "_blank",
            download = NA,
            shiny::icon("download", "fa-3x", lib = "font-awesome"),
            shiny::tags$br(),
            shiny::tags$label(`for`="digest-download-img", "Save")
        ),
        actionButtonWithCustomClass("requestDigestUpload", label = "", cssClasses = "digest-button btn-sq btn-sq-sm btn-red text-center",
            shiny::icon("upload", "fa-3x", lib = "font-awesome"),
            shiny::tags$br(),
            shiny::tags$label(`for`="digest-upload-img", "Load")
        )
    )
}
