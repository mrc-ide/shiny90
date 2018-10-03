plotInputs <- function(output, surveyAndProgramData, spectrumFilesState) {

    output$reviewTotalPop <- shiny::renderPlot({
        first90::plot_pjnz_pop(spectrumFilesState$pjnz_summary())
    })

    output$reviewPLHIV <- shiny::renderPlot({
        first90::plot_pjnz_plhiv(spectrumFilesState$pjnz_summary())
    })

    output$reviewPrevalence <- shiny::renderPlot({
        first90::plot_pjnz_prv(spectrumFilesState$pjnz_summary())
    })

    output$reviewIncidence <- shiny::renderPlot({
        first90::plot_pjnz_inc(spectrumFilesState$pjnz_summary())
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
