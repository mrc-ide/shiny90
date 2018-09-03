library(shiny)

workingSet <- function(input, output) {
    workingSet <- reactiveVal(
    list(name=NULL, notes=NULL)
    )
    output$workingSetSelected <- reactive({ !is.null(workingSet()$name) })
    output$workingSet_name <- reactive({ workingSet()$name })
    output$workingSet_notes <- reactive({ workingSet()$notes })
    output$workingSet_new_error <- reactive({NULL})
    observeEvent(input$startNewWorkingSet, {
        if (input$workingSetName != "") {
            workingSet(list(name=input$workingSetName, notes="Cupcake ipsum dolor sit amet. Dessert gummies tootsie roll croissant pudding. Marzipan cookie jujubes cotton candy lollipop. Dessert ice cream soufflé.

Marzipan jelly beans candy canes biscuit. Chocolate cake tart jelly beans marzipan cookie toffee gingerbread carrot cake gummi bears. Chocolate pastry dessert apple pie liquorice biscuit ice cream pastry macaroon."))
            output$workingSet_new_error <- reactive({NULL})
        } else {
            output$workingSet_new_error <- reactive({"A name is required"})
        }
    })
    outputOptions(output, "workingSet_new_error", suspendWhenHidden = FALSE)
    outputOptions(output, "workingSetSelected", suspendWhenHidden = FALSE)
}
