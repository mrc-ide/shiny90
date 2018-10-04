# shiny90
Shiny tool for the first 90 HIV model (https://github.com/mrc-ide/first90)

## Prerequisites
* R

## Install dependencies
Run

```
./bootstrap
```

to install R dependencies. If your system doesn't suppport bash, then instead 
run `./bootstrap.R`.

## Run app
To run the app, use `./app.R`


To run the app with the model in an inaccurate, but much faster mode for 
testing, use:

```
SHINY90_TEST_MODE=TRUE ./app.R
```

## Tests
```
sudo ./install_geckodriver.sh
./test
```

They should also run at https://circleci.com/gh/mrc-ide/workflows/shiny90

# Sample files
Available on SharePoint [here](https://imperiallondon-my.sharepoint.com/:f:/r/personal/epidem_ic_ac_uk/Documents/UNAIDS%20Ref%20Group%20Shared%20Drive/Ref%20Group%20Meetings/Meetings%202018/first%2090%20workshop%20-%20Wisbech%20August%202018?csf=1&e=MFospr)

Or if you access to the private repo, you can get at sample files via the submodule:

```
git submodule init
git submodule update
ls sample_files
```