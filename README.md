# shiny90
Shiny tool for the first 90 HIV model (https://github.com/mrc-ide/first90)

[![Travis-CI Build Status](https://travis-ci.com/mrc-ide/shiny90.svg?branch=master)](https://travis-ci.com/mrc-ide/shiny90)

## Prerequisites
* R

## Install dependencies
Run

```
./scripts/bootstrap
```

to install R dependencies. If your system doesn't suppport bash, then instead 
run `./scripts/bootstrap.R`.

## Run app
### Unix
To run the app: `./run.R`

To run the app with an inaccurate model for quick testing:

```
SHINY90_TEST_MODE=TRUE ./run.R
```

### Windows
1. Install R for windows: https://cran.r-project.org/bin/windows/base/
2. Run `scripts/bootstrap.bat` by double clicking on it - this will install dependencies
3. Run `launch.bat` by double clicking it to launch the app

## Tests

For unit tests:
```
./scripts/bootstrap-dev.R
./scripts/unittest
```

For Selenium tests:
```
sudo ./scripts/install_geckodriver.sh
./scripts/test
```

They should also run at https://travis-ci.org/mrc-ide/shiny90

# Sample files
Available on SharePoint [here](https://imperiallondon-my.sharepoint.com/:f:/r/personal/epidem_ic_ac_uk/Documents/UNAIDS%20Ref%20Group%20Shared%20Drive/Ref%20Group%20Meetings/Meetings%202018/first%2090%20workshop%20-%20Wisbech%20August%202018?csf=1&e=MFospr)

Or if you access to the private repo, you can get at sample files via the submodule:

```
git submodule init
git submodule update
ls sample_files
```

# Build a USB stick

```r
install.packages("drat")
drat:::add("mrc-ide")
install.packages(c("provisionr", "buildr", "nomad"))

source("scripts/build_library.R")
build_usb("destination")
```
