# Read-only prerequisite check. Restore first with the README commands.
required <- readLines('scripts/required-packages.txt')
failed <- FALSE
cat('R:', as.character(getRversion()), '\n')
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  cat('Missing R packages:', paste(missing, collapse = ', '), '\n')
  failed <- TRUE
}
if (requireNamespace('jsonlite', quietly = TRUE)) {
  lock <- jsonlite::read_json('renv.lock')
  invalid <- names(Filter(function(record) {
    is.null(record$Package) || is.null(record$Version) || !nzchar(record$Version)
  }, lock$Packages))
  unrecorded <- setdiff(required, names(lock$Packages))
  if (length(invalid) || length(unrecorded) || !length(lock$Packages)) {
    cat('Incomplete lockfile records:', paste(unique(c(invalid, unrecorded)), collapse = ', '), '\n')
    failed <- TRUE
  }
  if (as.character(getRversion()) != lock$R$Version) {
    cat('Recorded R version:', lock$R$Version, '(use this version for reproduction)\n')
    failed <- TRUE
  }
  installed <- installed.packages()
  absent <- setdiff(names(lock$Packages), installed[, 'Package'])
  if (length(absent)) {
    cat('Recorded packages not installed:', paste(absent, collapse = ', '), '\n')
    failed <- TRUE
  }
  mismatches <- names(Filter(function(record) {
    !is.null(record$Version) && record$Package %in% installed[, 'Package'] &&
      package_version(installed[match(record$Package, installed[, 'Package']), 'Version']) !=
      package_version(record$Version)
  }, lock$Packages))
  if (length(mismatches)) {
    cat('Package versions differ from renv.lock:', paste(mismatches, collapse = ', '), '\n')
    failed <- TRUE
  }
}
for (tool in c('quarto', 'python3', 'node', 'npm')) {
  path <- Sys.which(tool)
  if (!nzchar(path)) {
    cat('Missing tool:', tool, '\n'); failed <- TRUE
  } else {
    version <- tryCatch(system2(path, '--version', stdout = TRUE, stderr = TRUE),
                        error = function(e) structure(conditionMessage(e), status = 1L))
    cat(tool, ':', paste(version, collapse = ' '), '\n')
    if (!is.null(attr(version, 'status'))) failed <- TRUE
    if (tool == 'quarto' && version[1] != '1.10.19') {
      cat('Quarto 1.10.19 is required for the recorded build.\n'); failed <- TRUE
    }
    if (tool == 'python3' &&
        (!grepl('^Python [0-9]+[.][0-9]+', version[1]) ||
         package_version(sub('^Python ', '', version[1])) < package_version('3.9'))) {
      cat('Python 3.9 or newer is required.\n'); failed <- TRUE
    }
    if (tool == 'node' && !grepl('^v(2[4-9]|[3-9][0-9])[.]', version[1])) {
      cat('Node.js 24 or newer is required.\n'); failed <- TRUE
    }
  }
}
if (!file.exists('node_modules/pagefind/package.json')) {
  cat('Pagefind is missing. Run npm ci.\n'); failed <- TRUE
}
if (failed) {
  cat('Setup incomplete; follow README.md to restore dependencies.\n')
  quit(status = 1L)
}
cat('All recorded packages and required tools are available.\n')
