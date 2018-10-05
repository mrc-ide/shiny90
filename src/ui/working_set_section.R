workingSetSection <- function() {
    shiny::div("", class = "working-set",
        shiny::div("",
            shiny::tags$strong("Current working set:"),
            shiny::span("",
                shiny::textOutput("workingSet_name", inline = TRUE)
            ),
            shiny::div("", class = "pull-right",
                edit_link("editWorkingSet")
            )
        ),
        shiny::div("",
            shiny::tags$strong("Working set notes:", style="vertical-align: top"),
            shiny::div("", class="working-set-notes",
                shiny::verbatimTextOutput("workingSet_notes")
            )
        ),
        # Fades out notes that are too long to fit in box
        shiny::div("", style = "position: absolute; bottom: 0; left: 0; right: 0; height: 50px;
                                background: linear-gradient(to bottom, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 1) 100%);")
    )
}