library(testthat)
root <- normalizePath(if (file.exists('_quarto.yml')) '.' else '..')
lesson <- function(stem) {
  env <- new.env(parent=globalenv())
  grDevices::pdf(tempfile(fileext='.pdf'))
  on.exit(grDevices::dev.off())
  invisible(capture.output(sys.source(file.path(root,'course3_design_causal/code',paste0(stem,'.R')),envir=env)))
  env
}

test_that('non-inferiority uses new minus comparator with a matching interval', {
  e <- lesson('lab_week1_session3')
  newer <- e$trial$y[e$trial$arm=='new']; control <- e$trial$y[e$trial$arm=='comparator']
  estimate <- mean(newer)-mean(control)
  se <- sqrt(var(newer)/length(newer)+var(control)/length(control))
  expect_equal(e$est,estimate,tolerance=1e-12)
  expect_equal(mean(e$ci),estimate,tolerance=1e-12)
  expect_lt(e$ci[1],estimate-1.9*se)
  expect_equal(e$ni_pass,e$ci[1]>-3)
})

test_that('trial comparisons distinguish randomisation, adherence, and received treatment', {
  e <- lesson('lab_week1_session2');d<-e$trial
  expect_equal(e$itt_diff,mean(d$y[d$arm=='treatment'])-mean(d$y[d$arm=='placebo']))
  expect_equal(e$pp_diff,mean(d$y[d$arm=='treatment' & !d$crossed])-mean(d$y[d$arm=='placebo']))
  expect_equal(e$at_diff,mean(d$y[d$received=='treatment'])-mean(d$y[d$received=='placebo']))
  expect_false(isTRUE(all.equal(e$pp_diff,e$at_diff)))
  expect_equal(mean(e$itt$conf.int),e$itt_diff)
})

test_that('the factorial interaction is present and compares the intended reference cells', {
  e <- lesson('lab_week1_session4')
  expect_true('drugyes:dietmodified' %in% names(coef(e$fit)))
  means <- with(e$fact,tapply(y,list(drug,diet),mean))
  expected <- means['yes','modified']-means['no','modified']-means['yes','standard']+means['no','standard']
  expect_equal(unname(coef(e$fit)['drugyes:dietmodified']),unname(expected),tolerance=1e-12)
})

test_that('the downloadable cluster power lesson runs the planned model', {
  e <- lesson('lab_week1_session5')
  expect_true(all(is.finite(e$dat$y)))
  expect_equal(nrow(e$ps$errors),0L)
  expect_equal(nrow(e$ps$warnings),0L)
  expect_true(all(vapply(split(e$dat$arm,e$dat$cluster),function(x) length(unique(x))==1L,logical(1))))
  expect_equal(as.numeric(lme4::VarCorr(e$m0)$cluster),.5)
  expect_true(summary(e$ps)$mean >= 0 && summary(e$ps)$mean <= 1)
})
