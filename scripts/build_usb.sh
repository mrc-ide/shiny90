#!/usr/bin/env bash

here=$(dirname "$0")

$here/compile.R

mkdir usb

cp .Renviron LICENSE app.R run.R launch.bat usb
cp images src usb -r
cp compiled usb/packages -r
