library(shiny)

digestButtons <- function() {
    div("", style="width: 64px; display: inline-block",
        a("", href="#", class="digest-button btn-sq btn-sq-sm btn btn-red btn-default text-center",
            img(id="digest-download", src="images/cloud-download-red.svg", width=32, height=32),
            tags$br(),
            tags$label(`for`="digest-download", "Save")
        ),
        a("", href="#", class="digest-button btn-sq btn-sq-sm btn btn-red btn-default text-center",
            img(id="digest-upload", src="images/cloud-upload-red.svg", width=32, height=32),
            tags$br(),
            tags$label(`for`="digest-upload", "Load")
        )
    )
}
