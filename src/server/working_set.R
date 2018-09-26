workingSetLogic <- function(input, output, session, workingSet) {
    # Outputs
    output$workingSet_selected <- shiny::reactive({ !is.null(workingSet$name) })
    output$workingSet_name <- shiny::reactive({ workingSet$name })
    output$workingSet_notes <- shiny::reactive({ workingSet$notes })
    output$workingSet_creation_error <- shiny::reactive({ workingSet$creation_error })

    # Creating a new one
    shiny::observeEvent(input$startNewWorkingSet, {
        if (input$workingSetName != "") {
            workingSet$name <- input$workingSetName
            workingSet$notes <- ""
            workingSet$creation_error <- NULL
        } else {
            workingSet$creation_error <- "A name is required"
        }
    })
    shiny::outputOptions(output, "workingSet_creation_error", suspendWhenHidden = FALSE)
    shiny::outputOptions(output, "workingSet_selected", suspendWhenHidden = FALSE)

    # Editing
    shiny::observeEvent(input$editWorkingSet, {
        workingSet$editing = TRUE
        shiny::updateTextInput(session, "editWorkingSet_name", value = workingSet$name)
        shiny::updateTextInput(session, "editWorkingSet_notes", value = workingSet$notes)
    })
    shiny::observeEvent(input$editWorkingSet_cancel_cross, { workingSet$editing <- FALSE })
    shiny::observeEvent(input$editWorkingSet_cancel_button, { workingSet$editing <- FALSE })
    shiny::observeEvent(input$editWorkingSet_update, {
        workingSet$editing <- FALSE
        workingSet$name <- input$editWorkingSet_name
        workingSet$notes <- input$editWorkingSet_notes
    })

    workingSet
}
