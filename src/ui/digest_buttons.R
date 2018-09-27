digestButtons <- function() {
    shiny::div("", style = "width: 64px; display: inline-block",
        shiny::a(id='digestDownload1',
            class = "btn btn-default shiny-download-link digest-button btn-sq btn-sq-sm btn-red text-center",
            href = "",
            target = "_blank",
            download = NA,
            shiny::img(id = "digest-download-img", src = "images/cloud-download-red.svg", width = 32, height = 32),
            shiny::tags$br(),
            shiny::tags$label(`for`="digest-download-img", "Save")
        ),
        actionButtonWithCustomClass("requestDigestUpload", label = "", cssClasses = "digest-button btn-sq btn-sq-sm btn-red text-center",
            shiny::img(id = "digest-upload-img", src = "images/cloud-upload-red.svg", width = 32, height = 32),
            shiny::tags$br(),
            shiny::tags$label(`for`="digest-upload-img", "Load")
        )
    )
}
