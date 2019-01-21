workingSetSection <- function() {
    shiny::div("", class = "working-set",
        shiny::div("", class = "pull-right",
            edit_link("editWorkingSet")
        ),
        shiny::div("",
            shiny::tags$strong("Country or region:"),
            shiny::span(id = "workingSet_name", class = "shiny-text-output"),
            shiny::tags$br(),
            shiny::tags$strong("Working set notes:"),
            shiny::div("", class="working-set-notes",
                shiny::span(id = "workingSet_notes", class = "shiny-text-output")
            )
        )
    )
}