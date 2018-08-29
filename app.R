#!/usr/bin/env Rscript
library(shiny)

ui <- fluidPage(
	#includeCSS("style.css"),
	div(class="row align-items-center mb-3",
		div("Shiny 90")
	),
	div(class="row main-content",
		div(class="col-md-3 col-lg-2 col-sm-12 sidebar nopadding",
			tags$ol(class="nav", `data-bind`="foreach: sections",
				tags$li(class="nav-item",
					a(class="nav-link", href="#", `data-bind`="text: $data, click: $parent.onClick, css: { active: $parent.currentSection() == $data }", "")
				)
			)
		),
		div(class="col-md-9",
			h1(`data-bind`="text: currentSection"),
			div(`data-bind`="visible: currentSection().id() == 'spectrum'",
			    fileInput("surveyData", "Choose CSV File",
			        accept = c("text/csv","text/comma-separated-values,text/plain",".csv")),
				    tableOutput(outputId = "surveyContents")

			),
		)
	),
	includeScript("scripts/knockout.js"),
	includeScript("scripts/ui.js")
)

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

app <- shinyApp(ui = ui, server = server)
runApp(app, port=8080)