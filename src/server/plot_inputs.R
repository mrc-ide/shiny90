plotInputs <- function(output, surveyAndProgramData, spectrumFilesState) {

    output$reviewTotalPop <- shiny::renderPlot({
        if (spectrumFilesState$anyDataPop()){
           first90::plot_pjnz_pop(spectrumFilesState$pjnz_summary())
        }
    })

    output$reviewPLHIV <- shiny::renderPlot({
        if (spectrumFilesState$anyDataPlhiv()){
            first90::plot_pjnz_plhiv(spectrumFilesState$pjnz_summary())
        }
    })

    output$reviewPrevalence <- shiny::renderPlot({
        if (spectrumFilesState$anyDataPrv()){
            first90::plot_pjnz_prv(spectrumFilesState$pjnz_summary())
        }
    })

    output$reviewIncidence <- shiny::renderPlot({
        if (spectrumFilesState$anyDataInc()){
            first90::plot_pjnz_inc(spectrumFilesState$pjnz_summary())
        }
    })

    output$reviewTotalTests <- shiny::renderPlot({
        if (surveyAndProgramData$anyProgramDataTot()) {
            first90::plot_input_tot(surveyAndProgramData$program_data, spectrumFilesState$combinedData())
        }
    })

    output$reviewTotalPositive <- shiny::renderPlot({
        if (surveyAndProgramData$anyProgramDataTotPos()){
            first90::plot_input_totpos(surveyAndProgramData$program_data, spectrumFilesState$combinedData())
        }
    })

    output$reviewTotalANC <- shiny::renderPlot({
        if (surveyAndProgramData$anyProgramDataAnc()){
            first90::plot_input_anctot(surveyAndProgramData$program_data, spectrumFilesState$combinedData())
        }
    })

    output$reviewTotalANCPositive <- shiny::renderPlot({
        if (surveyAndProgramData$anyProgramDataAncPos()) {
            first90::plot_input_ancpos(surveyAndProgramData$program_data, spectrumFilesState$combinedData())
        }
    })

}
