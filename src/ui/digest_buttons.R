library(shiny)

digestButtons <- function() {
    div("", style="width: 64px; display: inline-block",
        a(id='digestDownload',
            class="btn btn-default shiny-download-link digest-button btn-sq btn-sq-sm btn-red text-center",
            href="",
            target="_blank",
            download=NA,
            img(id="digest-download-img", src="images/cloud-download-red.svg", width=32, height=32),
            tags$br(),
            tags$label(`for`="digest-download-img", "Save")
        ),
        actionButtonWithCustomClass("requestDigestUpload", label="", cssClasses="digest-button btn-sq btn-sq-sm btn-red text-center",
            img(id="digest-upload-img", src="images/cloud-upload-red.svg", width=32, height=32),
            tags$br(),
            tags$label(`for`="digest-upload-img", "Load")
        )
    )
}
