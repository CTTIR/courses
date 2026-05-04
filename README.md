# Biostatistics Courses

A four-course biostatistics programme in R and Quarto, hosted on GitHub Pages.
Standalone courses site, referenced from the owner's main website.

- Course 1 — Foundations of Biostatistics with R
- Course 2 — Regression, ANOVA & Model Diagnostics
- Course 3 — Study Design, Longitudinal Data & Causal Inference
- Course 4 — Modern Statistical Learning & High-Dimensional Biomedicine

Every inference lab follows the five-step template:
Hypothesis → Visualise → Assumptions → Conduct → Conclude.

Every lab renders twice from one Quarto source: as an HTML article and
as a Reveal.js slide deck.

## Acknowledgements

Heartfelt thanks to **Chi Zhang** and the OCBE team at the University of Oslo
(https://ocbe-uio.github.io/teaching_mf9130e/) for the direct structural
inspiration. See `references.qmd` for the full list of sources.

## Build

```bash
git clone https://github.com/CHANGE_ME/biostats_curriculum.git
cd biostats_curriculum
Rscript setup_check.R
Rscript -e 'renv::restore()'
quarto render        # builds articles + slides
quarto preview
```

## URL
https://r-heller.github.io/courses/

## Licence

MIT.
