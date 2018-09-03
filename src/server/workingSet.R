library(shiny)

workingSet <- function(input, output) {
    workingSet <- reactiveValues()
    workingSet$name <- NULL
    workingSet$notes <- NULL
    workingSet$creation_error <- NULL

    output$workingSet_selected <- reactive({ !is.null(workingSet$name) })
    output$workingSet_name <- reactive({ workingSet$name })
    output$workingSet_notes <- reactive({ workingSet$notes })
    output$workingSet_creation_error <- reactive({ workingSet$creation_error })

    observeEvent(input$startNewWorkingSet, {
        if (input$workingSetName != "") {
            workingSet$name <- input$workingSetName
            workingSet$notes <- "Cupcake ipsum dolor sit amet. Dessert gummies tootsie roll croissant pudding. Marzipan cookie jujubes cotton candy lollipop. Dessert ice cream soufflé.\n\nMarzipan jelly beans candy canes biscuit. Chocolate cake tart jelly beans marzipan cookie toffee gingerbread carrot cake gummi bears. Chocolate pastry dessert apple pie liquorice biscuit ice cream pastry macaroon."
            output$creation_error <- NULL
        } else {
            output$creation_error <- "A name is required"
        }
    })
    outputOptions(output, "workingSet_creation_error", suspendWhenHidden = FALSE)
    outputOptions(output, "workingSet_selected", suspendWhenHidden = FALSE)
}
