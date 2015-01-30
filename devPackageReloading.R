# Run user's .Rprofile too if they have one
if (file.exists("~/.Rprofile"))
    source("~/.Rprofile")

# Directory we will install files to
dev_lib <- file.path(getwd(), ".Rpackages-local")

# Detach and reinstall given package
reinstall <- function () {
    parse_deps <- function (deps) {
        deps <- gsub("\\(.*?\\)", "", deps)
        deps <- unlist(strsplit(deps, "\\W+"))
        Filter(nzchar, deps)
    }

    # Make sure the directory to install to exists
    dir.create(dev_lib, showWarnings = FALSE)

    # Read dependencies, ignore what's already installed
    dcf <- read.dcf("DESCRIPTION")
    deps <- c(
        parse_deps(dcf[,"Imports"]),
        parse_deps(dcf[,"Suggests"])
    )
    deps <- deps[!file.exists(file.path(dev_lib, deps))]

    # Install anything left over
    if(length(deps) > 0) {
        utils::install.packages(deps, dependencies = TRUE, lib = dev_lib)
    }

    # Detach (if already loaded), and reinstall
    name <- dcf[,"Package"]
    pkg <- paste0("package:", name)
    if (pkg %in% search()) {
        detach(name = pkg, unload=TRUE, character.only = TRUE)
    }
    utils::install.packages(".", repos = NULL, lib = dev_lib)
    library(name, character.only = TRUE, lib.loc = dev_lib)
    cat("\nInstalled", name, "- you may have to restart R if you added help pages or data.\n")
    cat("Run reinstall() to reinstall & reload\n")
}

# Run all tests for packages currently developing
source_tests <- function (pattern = "\\.R$") {
    for (test in dir('tests', pattern = pattern, full.names = TRUE)) {
        cat("====", test, "====\n")
        source(test, chdir = TRUE)
    }
}

# If starting an interactive session, launch reinstall() straight away
if (interactive()) reinstall()
