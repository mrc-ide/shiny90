file.readText <- function(path) {
    readChar(path, file.info(path)$size)
}

file.writeText <- function(path, text) {
    f <- file(path)
    on.exit(close(f))
    writeLines(text, f)
}

invert <- function(f) function(...) -f(...)

OptimisationCounter <- methods::setRefClass("OptimisationCounter",fields=list(iteration="numeric",
                                                                                par="numeric"))

