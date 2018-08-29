navigation_panel <- function() { div(class="col-md-3 col-lg-2 col-sm-12 sidebar nopadding",
        tags$ol(class="nav", `data-bind`="foreach: sections",
            tags$li(class="nav-item",
                a(class="nav-link", href="#", `data-bind`="text: $data.name, click: $parent.onClick, css: { active: $parent.currentSection().id() == $data }", "")
            )
        )
    )
}

content_panel <- function() {
    div(class="col-md-9",
        h1(`data-bind`="text: currentSection().name()"),
        div(`data-bind`="visible: currentSection().id() == 'spectrum'",
            panel_spectrum()
        )
    )
}

panel_spectrum <- function() { 
    div("",
        div("Help text for this page: Cupcake ipsum dolor sit amet cotton candy soufflé topping. Icing dessert brownie jujubes lollipop topping. Cotton candy chocolate cake danish apple pie carrot cake wafer chocolate bar oat cake.",
            class="mb-3"),
        fileInput("surveyData", "Choose CSV File",
                  accept = c("text/csv","text/comma-separated-values,text/plain",".csv")),
        tableOutput(outputId = "surveyContents")
    )
}