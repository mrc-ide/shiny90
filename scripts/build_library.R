## requires:
## * buildr from mrc-ide/buildr
## * provisionr from mrc-ide/provisionr
## * nomad from reconhub/nomad
## * drat from CRAN

build_usb <- function(destination, path = ".", r_version = "3.5") {
  if (file.exists(destination)) {
    message("Skipping building CRAN")
  } else {
    nomad::build_path(path, destination)
  }
  build_library(destination)
}


## Largely derived from didehpc:::initialise_cluster_packages_build
build_library <- function(destination, r_version = "3.5") {
  build_server_host <- "builderhv.dide.ic.ac.uk"
  build_server_port <- 8735
  path_lib <- file.path(destination, "windows")

  src <- provisionr::package_sources(repos = paste0("file://", destination))
  packages <- readLines(file.path(destination, "package_list.txt"))
  res <- provisionr::provision_library(packages, path_lib,
                                       platform = "windows", src = src,
                                       allow_missing = TRUE)

  missing <- res$missing
  if (is.null(missing)) {
    return()
  }
  url <- sprintf("%s/%s_%s.%s", missing[, "Repository"],
                 missing[, "Package"], missing[, "Version"], "tar.gz")

  tmp <- tempfile()
  dir.create(tmp)
  for (u in url) {
    ## The switch here and the file.copy should not be necessary, but
    ## on windows I see download.file a truncated (~100 byte file)
    ## rather than the full download.
    dest <- file.path(tmp, basename(u))
    if (grepl("^file://", u)) {
      file.copy(provisionr:::file_unurl(u), dest, overwrite = TRUE)
    } else {
      download.file(u, dest, mode = "wb")
    }
  }

  ## TODO: this is a 1 hour timeout which seems more than enough.  I
  ## think that we could make this configurable pretty happily but
  ## we'd want to do that via either an option, possibly paired with a
  ## config option.  For now, leaving it as it is.
  bin <- buildr::build_binaries(file.path(tmp, basename(url)),
                                build_server_host, build_server_port,
                                timeout = 3600)

  ## TODO: this somewhat duplicates a little of the cross
  ## installation, but it's not a great big deal really.  We *do*
  ## need to remove existing package directories first though, or
  ## the packages could be inconsistent.  Thankfully getting the
  ## full name is not a huge deal
  extract <- unzip

  dest_full <- file.path(path_lib, rownames(missing))
  unlink(dest_full[file.exists(dest_full)], recursive = TRUE)

  for (b in bin) {
    extract(b, exdir = path_lib)
    drat:::insert(b, destination, commit = FALSE)
  }

  ## Add the binaries to the windows mini-cran
  dest_bin <- file.path(destination, "bin/windows/contrib", r_version)
  file.copy(bin, dest_bin)
  tools::write_PACKAGES(dest_bin, type = "win.binary")
}
