panelAdvanced <- function() {

    withSpinner <- shinycssloaders::withSpinner

    shiny::div("", id="advanced-outputs",
        class="pt-5",
        shiny::tabsetPanel(
            shiny::tabPanel("Figures",
                shiny::div("", class = "row pt-5",
                    shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_retest_neg"))),
                    shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_retest_pos")))
                ),
                shiny::div("", class="row",
                    shiny::div("", class = "col-md-6 col-sm-12", withSpinner(shiny::plotOutput(outputId = "outputs_prv_pos_yld")))
                )
            ),
            shiny::tabPanel("Estimated parameters",
                div("", class="output-table outputs-parameters pt-3",
                    shiny::dataTableOutput("outputs_advanced_params")
                )
            ),
            shiny::tabPanel("Pregnant women",
                div("", class="output-table outputs-preg pt-3",
                    shiny::dataTableOutput("outputs_tab_out_pregprev")
                )
            )
        )
    )
}
