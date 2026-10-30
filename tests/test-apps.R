library(testthat)
root <- normalizePath(if (file.exists('_quarto.yml')) '.' else '..')
app_defaults <- list(
  'clt-explorer' = list(dist='unif',n=30,m=100,go=0),
  'bootstrap-ci' = list(stat='mean',dist='norm',n=50,B=200,conf=.95,go=0),
  'diagnostic-test' = list(sens=.9,spec=.95,prev=.05),
  'logistic-explorer' = list(n=500,b0=-1,b1=1,noise_sd=1,go=0),
  'anova-contrasts' = list(k=4,n_per=30,effect=1,noise=1,go=0),
  'lm-diagnostics' = list(n=100,slope=.7,noise=1,hetero=FALSE,outlier=FALSE,go=0),
  'missing-data-sim' = list(n=100,rho=.5,p_miss=.3,mech='mar',reps=50,go=0),
  'dag-explorer' = list(dag_choice='confounder',exposure='X',outcome='Y'),
  'regularization-path' = list(n=100,p=50,s=5,snr=2,alpha=1,go=0),
  'sir-simulator' = list(model='sir',R0=2.5,inf_period=7,lat_period=4,N=1000,I0=10,days=60),
  'cv-vs-nested' = list(n=50,p=20,k=5,reps=5,go=0),
  'decision-curves' = list(n=200,prev=.2,auc_base=.65,auc_new=.78,go=0)
)
app_outputs <- list(
  'clt-explorer'=c('parent_plot','sampling_plot','summary_text'),
  'bootstrap-ci'=c('sample_plot','boot_plot','ci_text'),
  'diagnostic-test'=c('table','vals','ppv_plot'),
  'logistic-explorer'=c('logistic_curve','roc_plot','calibration_plot','metrics'),
  'anova-contrasts'=c('box_plot','aov_table','tukey_table'),
  'lm-diagnostics'=c('scatter','resid_fitted','qq_plot','scale_loc','leverage','model_summary'),
  'missing-data-sim'=c('compare_plot','metrics','scatter_plot'),
  'dag-explorer'=c('dag_plot','adj_sets','indep'),
  'regularization-path'=c('path_plot','cv_plot','summary_text'),
  'sir-simulator'=c('traj_plot','summary_text'),
  'cv-vs-nested'=c('cv_plot','summary_text'),
  'decision-curves'=c('dca_plot','summary_text')
)
for (name in names(app_defaults)) local({
  app_name <- name; defaults <- app_defaults[[name]]; outputs <- app_outputs[[name]]
  test_that(paste(app_name, 'renders every teaching output'), {
    e <- new.env(parent=globalenv())
    sys.source(file.path(root,'shiny',app_name,'app.R'),envir=e)
    set.seed(123)
    shiny::testServer(e$server, {
      do.call(session$setInputs, defaults)
      for (id in outputs) {
        expect_warning(value <- output[[id]], NA)
        expect_false(is.null(value), info=paste(app_name,id))
      }
    })
  })
})

test_that('regularisation rejects more signals than predictors and recovers', {
  e <- new.env(parent=globalenv()); sys.source(file.path(root,'shiny/regularization-path/app.R'),e)
  shiny::testServer(e$server, {
    session$setInputs(n=50,p=10,s=20,snr=2,alpha=1,go=0)
    expect_error(d(), 'must not exceed')
    session$setInputs(s=5)
    expect_equal(length(d()$beta),10)
    expect_warning(output$path_plot,NA)
  })
})

test_that('DAG errors are visible and empty sets differ from unidentifiable effects', {
  e <- new.env(parent=globalenv()); sys.source(file.path(root,'shiny/dag-explorer/app.R'),e)
  shiny::testServer(e$server, {
    session$setInputs(dag_choice='custom',dag_text='dag { X -> }',exposure='X',outcome='Y')
    expect_error(dag(),'Invalid DAG')
    session$setInputs(dag_text='dag {X -> Y}')
    expect_match(output$adj_sets,'empty adjustment set')
    session$setInputs(dag_text='dag {U [unobserved]; U -> X; U -> Y; X -> Y}')
    expect_match(output$adj_sets,'No sufficient adjustment set')
    session$setInputs(exposure='absent')
    expect_error(dag(),'Exposure must name')
    session$setInputs(exposure='X',dag_text='dag {X -> Y; Y -> X}')
    expect_error(dag(),'cycle')
  })
})

test_that('one-class logistic samples produce a recovery message', {
  e <- new.env(parent=globalenv()); sys.source(file.path(root,'shiny/logistic-explorer/app.R'),e)
  e$rbinom <- function(n,...) rep(0,n)
  shiny::testServer(e$server, {
    session$setInputs(n=50,b0=-3,b1=0,noise_sd=1,go=0)
    expect_error(d(),'only one outcome class')
  })
})
