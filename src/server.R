server <- function(input, output) {
    workingSet(input, output)
    pjnzFilePath <- handleUploadAndReviewOfSpectrumFiles(input, output)
    reviewInputs(input, output)
    surveyAndProgramData <- surveyAndProgramData(input, output)
    modelRun(input, output, pjnzFilePath, surveyAndProgramData)
}
