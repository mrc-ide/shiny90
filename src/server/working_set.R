workingSetLogic <- function(input, output, session, workingSet, spectrumFileState) {
    # Outputs
    output$workingSet_selected <- shiny::reactive({ workingSet$selected || ! is.null(spectrumFileState$country)})
    output$workingSet_name <- shiny::reactive({ workingSet$name() })
    output$workingSet_notes <- shiny::reactive({ workingSet$notes})
    output$workingSet_creation_error <- shiny::reactive({ workingSet$creation_error})

    # Creating a new one
    workingSet$notes <- ""
    workingSet$selected <- FALSE
    workingSet$name <- shiny::reactive({
        if (is.null(spectrumFileState$country)) {
            "Unknown"
        }
        else {
            spectrumFileState$country
        }
    })

    shiny::observeEvent(input$startNewWorkingSet, {
        workingSet$selected <- TRUE
    })

    shiny::outputOptions(output, "workingSet_selected", suspendWhenHidden = FALSE)

    # Editing
    shiny::observeEvent(input$editWorkingSet, {
        workingSet$editing = TRUE
        shiny::updateTextInput(session, "editWorkingSet_notes", value = workingSet$notes)
    })
    shiny::observeEvent(input$editWorkingSet_cancel_cross, { workingSet$editing <- FALSE})
    shiny::observeEvent(input$editWorkingSet_cancel_button, { workingSet$editing <- FALSE})
    shiny::observeEvent(input$editWorkingSet_update, {
        workingSet$editing <- FALSE
        workingSet$notes <- input$editWorkingSet_notes
    })

    workingSet
}
