@echo off
for /f "tokens=3*" %%a in ('reg query HKLM\SOFTWARE\R-Core\R /v "Current Version"') do set "var=%%b"
for /f "tokens=2*" %%a in ('reg query HKLM\SOFTWARE\R-Core\R\%%var%% /v "InstallPath"') do set "var=%%b"
set path=%var%\bin;%path%
Rscript bootstrap.R
pause
