#!/usr/bin/env Rscript
library(shiny)

source("navigation.R")
source("server.R")

ui <- fluidPage(
	includeCSS("style.css"),
	includeCSS("bootstrap4.css"),
	div(class="row align-items-center mb-3",
		div("Shiny 90", class="header",
			tags$small("", class="pull-right",
				a("About this program and the underlying model", href="#")
			)
		)
	),
	div(class="row main-content",
		navigation_panel(),
		content_panel()
	),
	includeScript("scripts/knockout.js"),
	includeScript("scripts/ui.js")
)


app <- shinyApp(ui = ui, server = server)
options(shiny.autoreload=TRUE)
runApp(app, port=8080)