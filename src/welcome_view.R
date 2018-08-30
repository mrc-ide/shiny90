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
                                a("", href="#", class="btn-sq btn btn-info text-center",
                                    img(id="digest-upload", src="images/cloud-upload.svg", width=64, height=64),
                                    tags$br(),
                                    tags$label(`for`="digest-upload", "Load")
                                )
                            )
                        ),
                        div("", class="col-md-6 welcome-option form-group",
                            h3("Start a new blank working set"),
                            div("You will have the option to upload data from Spectrum and other data in a moment", class="mb-3"),
                            HTML("<label>Name:</label>"),
                            div("", class="input-group",
                                HTML("<input name='workingSetName' class='input-lg form-control' placeholder='(you can change this later)' id='workingSetName' type='text'>"),
                                div("", class="input-group-btn",
                                    div("Go", id="startNewWorkingSet", class="btn-lg btn btn-info action-button shiny-bound-input")
                                )
                            )
                        )
                    )
                )
            )
        )
    )
}