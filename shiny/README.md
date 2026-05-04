# Shiny apps for the biostatistics curriculum

Twelve self-contained Shiny apps that complement the labs, three per
course. Each app is a single `app.R` in its own folder, so each folder
maps directly to a Shiny Server route at
`https://<your-shiny-host>/<app-name>/`.

## Layout

```
shiny/
├── README.md                    # this file
├── clt-explorer/                # Course 1: CLT by simulation
├── bootstrap-ci/                # Course 1: bootstrap CI explorer
├── diagnostic-test/             # Course 1: Bayes / Se, Sp, PPV, NPV
├── lm-diagnostics/              # Course 2: linear-model diagnostics
├── logistic-explorer/           # Course 2: logistic curve, ROC, calibration
├── anova-contrasts/             # Course 2: one-way ANOVA + post-hoc
├── dag-explorer/                # Course 3: DAGs + adjustment sets
├── missing-data-sim/            # Course 3: MCAR / MAR / MNAR bias
├── sir-simulator/               # Course 3: SIR compartmental model
├── cv-vs-nested/                # Course 4: nested CV vs k-fold
├── regularization-path/         # Course 4: glmnet path explorer
└── decision-curves/             # Course 4: decision-curve / NRI
```

## Deploying to a Shiny Server

Each subdirectory is a complete app. To deploy to a self-hosted Shiny
Server (typical install at `/srv/shiny-server/`):

```bash
# Sync one app
rsync -avz shiny/clt-explorer/ user@your-host:/srv/shiny-server/clt-explorer/

# Sync them all at once
rsync -avz --exclude README.md shiny/ user@your-host:/srv/shiny-server/
```

After syncing, restart Shiny Server if needed:

```bash
sudo systemctl restart shiny-server
```

The apps will then be live at:

- `https://<your-host>/clt-explorer/`
- `https://<your-host>/bootstrap-ci/`
- ...etc.

## R packages required on the server

Install once with:

```r
install.packages(c(
  "shiny", "shinyWidgets", "ggplot2", "dplyr", "tidyr", "broom",
  "DT", "scales",
  "dagitty", "ggdag", "deSolve", "glmnet", "pROC", "MASS"
))
```

## Embedding into the courses website

The `shiny.qmd` page at the site root lists every app with a short
description and a link. To embed an app inside a lab page, use an
iframe:

```html
<iframe src="https://<your-host>/clt-explorer/" width="100%"
        height="650" frameborder="0"></iframe>
```

Or link out:

```markdown
[Open in a new tab](https://<your-host>/clt-explorer/){target="_blank"}
```

## Running an app locally

```bash
R -e 'shiny::runApp("shiny/clt-explorer", launch.browser = TRUE)'
```

## Conventions

- Each app uses `library()` for its packages at the top of `app.R`.
- No external data files. Everything is simulated or built-in.
- All ggplots use `theme_minimal()` and the site accent colour
  (`#1a73e8`) where colour mapping is discretionary.
- Each app has its own short README with a one-paragraph description
  and any teaching notes.
