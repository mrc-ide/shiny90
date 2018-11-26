welcomeView <- function() {
    shiny::fluidPage(
        shiny::div("", class = "welcome",
            shiny::fluidRow(class = "row align-items-center",
                shiny::div("", class = "col-md-8 col-sm-12 col-md-offset-2",
                shiny::h1("Shiny 90", class = "title"),
                    shiny::p("",
                        shiny::HTML('In 2014 UNAIDS launched the
                        <a href="http://www.unaids.org/en/resources/documents/2017/90-90-90">90-90-90</a> targets:'),
                        shiny::tags$ul("",
                            shiny::tags$li("By 2020, 90% of all people living with HIV will know their HIV status."),
                            shiny::tags$li("By 2020, 90% of all people with diagnosed HIV infection will receive sustained antiretroviral therapy."),
                            shiny::tags$li("By 2020, 90% of all people receiving antiretroviral therapy will have viral suppression.")
                        )
                    ),
                    shiny::p("This tool models the first 90: what percentage of the popultation living with HIV (plHIV) have been diagnosed?"),
                    shiny::p("",
                        shiny::span("To use the model, you will need your Spectrum national file or subnational files. Estimates
                            and data from Spectrum, including the population size, HIV prevalence, incidence (per thousand), people living
                            with HIV and ART coverage, will be combined with population-based survey and programmatic HIV testing data to
                            derive the first 90. The app comes with default survey and programmatic testing data abstracted from published reports,
                            but you can revise the default data or provide additional data as required."
                        )
                    ),
                    shiny::fluidRow(class = "row align-items-center mt-3",
                        shiny::div("", class = "col-md-6 welcome-option", style = "border-right: 1px solid rgb(200, 200, 200)",
                            shiny::h3("Open an existing Shiny 90 working set"),
                            shiny::div("This will be a file you downloaded from this app previously"),
                            shiny::div("", class = "text-center pt-4",
                                actionButtonWithCustomClass("welcomeRequestDigestUpload",
                                    label = "", cssClasses = "btn-sq btn-red text-center",
                                    shiny::icon("upload", "fa-3x", lib = "font-awesome"),
                                    shiny::tags$label(`for`="digest-upload-img", "Load")
                                )
                            )
                        ),
                        shiny::div("", class = "col-md-6 welcome-option form-group",
                            shiny::h3("Start a new blank working set"),
                            shiny::div("You will have the option to upload data in a moment", class = "mb-3"),
                            actionButtonWithCustomClass("startNewWorkingSet", "Go", cssClasses = "btn-sq btn-red text-center"),
                            shiny::conditionalPanel(
                                condition = "output.workingSet_creation_error",
                                shiny::div("", class = "has-error",
                                    shiny::div("", class = "help-block error",
                                        shiny::textOutput("workingSet_creation_error", inline = TRUE)
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