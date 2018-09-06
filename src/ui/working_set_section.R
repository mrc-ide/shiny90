library(shiny)

workingSetSection <- function() {
    div("", class="working-set",
        div("",
            tags$strong("Current working set:"),
            span("",
                textOutput("workingSet_name", inline=TRUE)
            ),
            div("", class="pull-right",
                edit_link("editWorkingSet")
            )
        ),
        div("",
            tags$strong("Working set notes:"),
            textOutput("workingSet_notes", inline=TRUE)
        ),
        # Fades out notes that are too long to fit in box
        div("", style="position: absolute; bottom: 0; left: 0; right: 0; height: 50px;
                                background: linear-gradient(to bottom, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 1) 100%);")
    )
}