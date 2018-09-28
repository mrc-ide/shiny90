plotInputs <- function(output, surveyAndProgramData, spectrumFilesState) {

    output$reviewTotalPop <- shiny::renderPlot({
        first90::plot_pnjz_pop(spectrumFilesState$combinedData())
    })

    output$reviewPLHIV <- shiny::renderPlot({
        first90::plot_pnjz_plhiv(spectrumFilesState$combinedData())
    })

    output$reviewPrevalence <- shiny::renderPlot({
        first90::plot_pnjz_prv(spectrumFilesState$combinedData())
    })

    output$reviewIncidence <- shiny::renderPlot({
        first90::plot_pnjz_inc(spectrumFilesState$combinedData())
    })

    output$reviewTotalTests <- shiny::renderPlot({
        first90::plot_input_tot(surveyAndProgramData$program(), spectrumFilesState$combinedData())
    })

    output$reviewTotalPositive <- shiny::renderPlot({
        first90::plot_input_totpos(surveyAndProgramData$program(), spectrumFilesState$combinedData())
    })

    output$reviewTotalANC <- shiny::renderPlot({
        first90::plot_input_anctot(surveyAndProgramData$program(), spectrumFilesState$combinedData())
    })

    output$reviewTotalANCPositive <- shiny::renderPlot({
        first90::plot_input_ancpos(surveyAndProgramData$program(), spectrumFilesState$combinedData())
    })

}
