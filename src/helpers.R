file.readText <- function(path) {
    readChar(path, file.info(path)$size)
}

file.writeText <- function(path, text) {
    f <- file(path)
    on.exit(close(f))
    writeLines(text, f)
}
