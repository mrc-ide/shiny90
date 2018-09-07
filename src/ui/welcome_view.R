library(shiny)

welcomeView <- function() {
    fluidPage(
        div("", class = "welcome",
            fluidRow(class = "row align-items-center",
                div("", class = "col-md-8 col-sm-12 col-md-offset-2",
                    h1("Shiny 90", class = "title"),
                    p("",
                        HTML('UN Aids have an ambitious treatment target to help end the AIDS epidemic,
                             <a href="http://www.unaids.org/en/resources/documents/2017/90-90-90">the threes 90s</a>:'),
                        tags$ul("",
                            tags$li("By 2020, 90% of all people living with HIV will know their HIV status."),
                            tags$li("By 2020, 90% of all people with diagnosed HIV infection will receive sustained antiretroviral therapy."),
                            tags$li("By 2020, 90% of all people receiving antiretroviral therapy will have viral suppression.")
                        )
                    ),
                    p("This tool models the 1st 90: what percentage of the popultation living with HIV (plHIV) have been diagnosed?"),
                    p("",
                        span("You will need input data from the UN AIDS"),
                        HTML('<a href="http://www.unaids.org/en/dataanalysis/datatools/spectrum-epp">Spectrum tool</a>.'),
                        span(
                            "This will be combined with survey and programmatic data. You can provide your own
                            survey and programmatic data, but the app comes with default data."
                        )
                    ),
                    fluidRow(class = "row align-items-center mt-3",
                        div("", class = "col-md-6 welcome-option", style = "border-right: 1px solid rgb(200, 200, 200)",
                            h3("Open an existing Shiny 90 working set"),
                            div("This will be a file you downloaded from this app previously"),
                            div("", class = "text-center pt-4",
                                actionButtonWithCustomClass("welcomeRequestDigestUpload",
                                    label = "", cssClasses = "btn-sq btn-red text-center",
                                    img(id = "digest-upload-img", src = "images/cloud-upload-red.svg", width = 64, height = 64),
                                    tags$br(),
                                    tags$label(`for`="digest-upload-img", "Load")
                                )
                            )
                        ),
                        div("", class = "col-md-6 welcome-option form-group",
                            h3("Start a new blank working set"),
                            div("You will have the option to upload data from Spectrum and other data in a moment", class = "mb-3"),
                            tags$label("Name:"),
                            div("", class = "input-group",
                                tags$input(id = "workingSetName",
                                    type = "text",
                                    name = "workingSetName",
                                    class = "shiny-bound-input input-lg form-control",
                                    placeholder = "(you can change this later)",
                                    `data-proxy-click` = "startNewWorkingSet"
                                ),
                                div("", class = "input-group-btn",
                                    actionButtonWithCustomClass("startNewWorkingSet", "Go", cssClasses = "btn-lg btn btn-red")
                                )
                            ),
                            conditionalPanel(
                                condition = "output.workingSet_creation_error",
                                div("", class = "has-error",
                                    div("", class = "help-block error",
                                        textOutput("workingSet_creation_error", inline = TRUE)
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
}