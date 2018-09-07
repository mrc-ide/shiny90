library(shiny)

workingSetLogic <- function(input, output, session, workingSet) {
    # Outputs
    output$workingSet_selected <- reactive({ !is.null(workingSet$name) })
    output$workingSet_name <- reactive({ workingSet$name })
    output$workingSet_notes <- reactive({ workingSet$notes })
    output$workingSet_creation_error <- reactive({ workingSet$creation_error })

    # Creating a new one
    observeEvent(input$startNewWorkingSet, {
        if (input$workingSetName != "") {
            workingSet$name <- input$workingSetName
            workingSet$notes <- ""
            workingSet$creation_error <- NULL
        } else {
            workingSet$creation_error <- "A name is required"
        }
    })
    outputOptions(output, "workingSet_creation_error", suspendWhenHidden = FALSE)
    outputOptions(output, "workingSet_selected", suspendWhenHidden = FALSE)

    # Editing
    observeEvent(input$editWorkingSet, {
        workingSet$editing = TRUE
        updateTextInput(session, "editWorkingSet_name", value = workingSet$name)
        updateTextInput(session, "editWorkingSet_notes", value = workingSet$notes)
    })
    observeEvent(input$editWorkingSet_cancel_cross, { workingSet$editing <- FALSE })
    observeEvent(input$editWorkingSet_cancel_button, { workingSet$editing <- FALSE })
    observeEvent(input$editWorkingSet_update, {
        workingSet$editing <- FALSE
        workingSet$name <- input$editWorkingSet_name
        workingSet$notes <- input$editWorkingSet_notes
    })

    workingSet
}
