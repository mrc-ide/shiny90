# Shiny90 digest for __COUNTRY__
This folder contains data exported from the UNAIDS Shiny90 app.

Principally, this file is intended to be used with that app - you can load this 
data into the app by uploading a zip file of this folder.

This file was created on __TIMESTAMP__.

## File descriptions
* notes.txt: Notes entered by the user (also included below in the 'User notes' section).
* survey.csv: Export of survey data dataframe in comma-separated format.
* program.csv: Export of programmatic data dataframe in comma-separated format.
* spectrum_data/*.rds: Data derived from spectrum files (pjnz). 
  Can be read by R using readRDS from the base library.
* model_outputs/spectrum_output.csv: Export of dataframe needed for 
re-ingestion by Spectrum in comma-separated format. Will only be present if the model has been run.
* model_outputs/optim.rds: Data output of running the model.
* model_outputs/simul.rds: Data about stochastic model run simulations. Only present when 
the model has been run with simulations.
  
## User notes
__NOTES__