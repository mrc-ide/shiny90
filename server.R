library(shiny)

server <- function(input, output) {
	output$surveyContents <- renderTable({
		# input$surveyData will be NULL initially. After the user selects
		# and uploads a file, it will be a data frame with 'name',
		# 'size', 'type', and 'datapath' columns. The 'datapath'
		# column will contain the local filenames where the data can
		# be found.
		inFile <- input$surveyData

		if (is.null(inFile))
		return(NULL)

		read.csv(inFile$datapath, header = TRUE)
	})

    output$results <- renderText({
        paste("You have selected", input$param1)
    })

    outputOptions(output, "results", suspendWhenHidden=FALSE)
}
