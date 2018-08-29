#!/usr/bin/env Rscript
library(shiny)

source("navigation.R")
source("server.R")

ui <- fluidPage(
	#includeCSS("style.css"),
	div(class="row align-items-center mb-3",
		div("Shiny 90")
	),
	div(class="row main-content",
		navigation_panel(),
		content_panel()
	),
	includeScript("scripts/knockout.js"),
	includeScript("scripts/ui.js")
)


app <- shinyApp(ui = ui, server = server)
runApp(app, port=8080)