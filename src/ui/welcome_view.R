library(shiny)

welcomeView <- function() {
    fluidPage(
        div("", class="welcome",
            fluidRow(class="row align-items-center",
                div("", class="col-md-8 col-sm-12 col-md-offset-2",
                    h1("Shiny 90", class="title"),
                    p("Some introductory text about the app Cupcake ipsum dolor sit amet bear claw dessert gummi bears. Donut cake toffee wafer. Caramels chocolate bar apple pie cake toffee."),
                    p("Danish jelly-o brownie tart ice cream chocolate bar jelly beans cheesecake carrot cake. Tart gingerbread sugar plum wafer halvah cookie candy canes danish. Candy canes bear claw cookie caramels. Tootsie roll biscuit dragée gingerbread gummi bears."),
                    fluidRow(class="row align-items-center mt-3",
                        div("", class="col-md-6 welcome-option", style="border-right: 1px solid black",
                            h3("Open an existing Shiny 90 working set"),
                            div("This will be a file you downloaded from this app previously"),
                            div("", class="text-center pt-4",
                                actionButtonWithCustomClass("welcomeRequestDigestUpload",
                                    label="", cssClasses="btn-sq btn-red text-center",
                                    img(id="digest-upload-img", src="images/cloud-upload-red.svg", width=64, height=64),
                                    tags$br(),
                                    tags$label(`for`="digest-upload-img", "Load")
                                )
                            )
                        ),
                        tags$form(
                            div("", class="col-md-6 welcome-option form-group",
                                h3("Start a new blank working set"),
                                div("You will have the option to upload data from Spectrum and other data in a moment", class="mb-3"),
                                tags$label("Name:"),
                                div("", class="input-group",
                                    tags$input(id="workingSetName",
                                        type="text",
                                        name="workingSetName",
                                        class="shiny-bound-input input-lg form-control",
                                        placeholder="(you can change this later)"
                                    ),
                                    div("", class="input-group-btn",
                                        actionButtonWithCustomClass("startNewWorkingSet", "Go",
                                            type="submit", cssClasses="btn-lg btn btn-red")
                                    )
                                ),
                                conditionalPanel(
                                    condition="output.workingSet_creation_error",
                                    div("", class="has-error",
                                        div("", class="help-block error",
                                            textOutput("workingSet_creation_error", inline=TRUE)
                                        )
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