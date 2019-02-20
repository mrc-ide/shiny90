#!/usr/bin/env bash

here=$(dirname "$0")
usb_dir="usb"
app_dir="${usb_dir}/app"

$here/compile.R

mkdir -p $app_dir

cp .Renviron LICENSE app.R run.R $here/launch.bat ${app_dir}
cp $here/windows_desktop_readme.md ${usb_dir}/README.md
cp images src ${app_dir}  -r
cp compiled/windows ${app_dir}/packages -r
cp compiled/extra ${usb_dir} -r
