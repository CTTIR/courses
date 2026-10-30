library(testthat)
root <- normalizePath(if (file.exists('_quarto.yml')) '.' else '..')
load_app <- function(name) {
  e <- new.env(parent = globalenv())
  sys.source(file.path(root, 'shiny', name, 'app.R'), envir = e)
  e
}

test_that('vectorised CV predictions agree with separate ordinary least squares fits', {
  e <- load_app('cv-vs-nested')
  set.seed(14); X <- matrix(rnorm(150), 30, 5); y <- rnorm(30)
  actual <- e$candidate_predictions(X[1:20, ], y[1:20], X[21:30, ])
  reference <- sapply(1:5, function(j) {
    fit <- lm(y ~ x, data = data.frame(y = y[1:20], x = X[1:20, j]))
    predict(fit, newdata = data.frame(x = X[21:30, j]))
  })
  expect_equal(unname(actual), unname(reference), tolerance = 1e-12)
  # Nested evaluation is unbiased in expectation; compare with exact conditional
  # test error, not the irreducible variance of the response.
  set.seed(482)
  estimates <- replicate(100, e$compare_cv(matrix(rnorm(80 * 25), 80), rnorm(80), 4))
  expect_lt(abs(mean(estimates['nested', ] - estimates['oracle', ])), 0.08)
  expect_lt(mean(estimates['naive', ]), mean(estimates['oracle', ]) - 0.05)
})

test_that('decision-curve probabilities use the population prevalence', {
  e <- load_app('decision-curves')
  set.seed(18); y <- rbinom(50000, 1, .1)
  expect_equal(e$simulate_pred(y, .5, .1), rep(.1, length(y)), tolerance = 1e-14)
  p <- e$simulate_pred(y, .8, .1)
  expect_lt(abs(mean(p) - .1), .006)
  expect_lt(abs(as.numeric(pROC::auc(y, p, quiet = TRUE, direction = '<')) - .8), .015)
  expect_equal(e$net_benefit(c(1, 0, 1, 0), c(.9, .8, .2, .1), .5), 0)
})

test_that('bootstrap mixture samples iid component memberships', {
  e <- load_app('bootstrap-ci'); set.seed(82)
  x <- e$draw('mix', 100000)
  expect_lt(abs(mean(x) - .5), .04)
  expect_lt(abs(var(x) - 3.25), .1)
})

test_that('requested missingness is the mean probability across mechanisms', {
  e <- load_app('missing-data-sim'); set.seed(28)
  for (mechanism in c('mcar', 'mar', 'mnar')) {
    x <- e$simulate_one(50000, .5, mechanism, .1)
    expect_lt(abs(mean(x$miss) - .1), .01)
  }
})

test_that('bootstrap correction has the intended no-overfit and maximal-overfit limits', {
  # Extract this independent teaching function without rerunning the whole lab.
  code <- parse(file.path(root, 'course4_ml_highdim/code/lab_week1_session1.R'))
  selected <- Filter(function(x) is.call(x) && identical(x[[1]], as.name('<-')) &&
    identical(x[[2]], as.name('bootstrap_errors')), as.list(code))
  e <- new.env(); eval(selected[[1]], e)
  expect_equal(unname(e$bootstrap_errors(1, 1, 2)[1:2]), c(1, 1))
  expect_equal(unname(e$bootstrap_errors(0, .5, .5)[1:2]), c(.316, .5))
  expect_equal(unname(e$bootstrap_errors(0, 1, .5)[1:2]), c(.632, .816))
  expect_equal(unname(e$bootstrap_errors(1, .5, .5)[1:2]), rep(.684, 2))
  expect_error(e$bootstrap_errors(NA, 1, 2))
})

test_that('SIR and SEIR conserve population and recover without transmission', {
  e <- load_app('sir-simulator')
  for (model in c('sir', 'seir')) {
    state <- if (model == 'sir') c(S = 990, I = 10, R = 0) else c(S = 990, E = 0, I = 10, R = 0)
    out <- deSolve::ode(state, 0:30, e[[paste0(model, '_eq')]], c(beta = 0, gamma = .2, sigma = .25))
    expect_equal(rowSums(out[, -1]), rep(1000, nrow(out)), tolerance = 1e-9)
    expect_equal(out[, 'I'], 10 * exp(-.2 * out[, 'time']), tolerance = 1e-5)
  }
})

survival_functions <- function() {
  code <- parse(file.path(root, 'course4_ml_highdim/code/lab_week3_session5.R'))
  e <- new.env(parent=as.environment('package:survival'))
  for (x in code) if (is.call(x) && identical(x[[1]], as.name('<-')) &&
    as.character(x[[2]]) %in% c('predict_surv','horizon_weights','score_horizon')) eval(x,e)
  e
}

test_that('Cox horizon predictions agree with survfit across a shifted cohort', {
  library(survival); e <- survival_functions()
  set.seed(79)
  d <- data.frame(x=rnorm(200,4),time=rexp(200),event=rbinom(200,1,.8))
  fit <- coxph(Surv(time,event) ~ x,data=d)
  nd <- data.frame(x=c(-2,1,4,8))
  for (t in c(0,.5,1)) {
    expected <- as.numeric(summary(survfit(fit,newdata=nd),times=t)$surv)
    expect_equal(unname(e$predict_surv(fit,nd,t)),expected,tolerance=1e-12)
  }
})

test_that('IPCW excludes unknown outcomes and weights observed cases and controls', {
  e <- survival_functions()
  d <- data.frame(time=1:4,event=c(1,0,1,1));p <- c(.8,.9,.2,.4)
  expect_equal(e$horizon_weights(d,2.5)$weights,c(1,0,1.5,1.5))
  expected <- ((1-.8)^2 + 1.5*.2^2 + 1.5*.4^2)/4
  expect_equal(unname(e$score_horizon(d,p,2.5)['brier']),expected)
  d$event <- 1
  expect_equal(unname(e$score_horizon(d,p,2.5)['brier']),mean((as.numeric(d$time<=2.5)-p)^2))
  expect_error(e$horizon_weights(data.frame(time=rep(1,4),event=0),2),'Insufficient')
})

test_that('IPCW approaches the complete-outcome Brier score under independent censoring', {
  e <- survival_functions();set.seed(214)
  n<-20000;x<-rnorm(n);event_time<-rexp(n,exp(.6*x-1));censor_time<-rexp(n,.15)
  d<-data.frame(time=pmin(event_time,censor_time),event=as.integer(event_time<=censor_time))
  risk<-1-exp(-3*exp(.6*x-1))
  expected<-mean((as.numeric(event_time<=3)-risk)^2)
  expect_lt(abs(unname(e$score_horizon(d,risk,3)['brier'])-expected),.01)
})

test_that('weighted time-dependent AUC agrees with explicit pairs including ties', {
  e <- survival_functions()
  d <- data.frame(time=c(1,2,3,4,5,6),event=c(1,0,1,1,1,0))
  p <- c(.8,.9,.4,.4,.2,.8);t<-3.5
  w <- e$horizon_weights(d,t)
  difference <- outer(p[w$cases],p[w$controls],'-')
  weights <- outer(w$weights[w$cases],w$weights[w$controls])
  expected <- sum(weights*((difference>0)+.5*(difference==0)))/sum(weights)
  expect_equal(unname(e$score_horizon(d,p,t)['auc']),expected,tolerance=1e-14)
})

test_that('RNA-seq simulation changes only the designated genes', {
  # Replace only the random draw with its expectation, then execute the actual
  # simulation expression. This detects scalar ifelse recycling across genes.
  code <- parse(file.path(root,'course4_ml_highdim/code/lab_week4_session1.R'))
  expr <- Filter(function(x) is.call(x) && identical(x[[1]],as.name('<-')) &&
    identical(x[[2]],as.name('counts')),as.list(code))[[1]]
  e <- new.env();e$n_gene<-4;e$n_samp<-2;e$group<-c('A','B');e$mu<-c(1,2,3,4)
  e$lfc<-c(log(3),0,log(2),0);e$rnbinom<-function(n,mu,size)mu
  eval(expr,e)
  expect_equal(e$counts[,1],c(1,2,3,4))
  expect_equal(e$counts[,2],c(3,2,6,4),tolerance=1e-12)
})
