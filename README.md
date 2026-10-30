# #courses

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

## Build and first use

Verified toolchain: R 4.6.1, Quarto 1.10.19, Python 3.9 or newer, Node.js
24 or newer, and Git. RStudio/Positron is optional. Native R dependencies
need a compiler and the system libraries described in [Get started](get_started.qmd).
The full dependency restore can take substantially longer than the site render.

```bash
git clone https://github.com/CTTIR/courses.git
cd courses
Rscript -e 'renv::restore(prompt=FALSE)'
npm ci
Rscript setup_check.R
quarto preview
```

`renv` activates a project library; `setup_check.R` only checks prerequisites
and exits nonzero on missing or mismatched requirements. It installs nothing.
The lockfile covers executable lessons and apps. Clearly marked, unevaluated
sketches (for example external omics data or optional Bayesian software) require
additional setup described in those lessons.

For a complete qualification build, recompute every article and slide:

```bash
npm test
python3 -m unittest discover -s tests -p 'test_*.py'
Rscript -e 'testthat::test_dir("tests", stop_on_failure=TRUE, stop_on_warning=TRUE)'
python3 scripts/check_labs.py --log-dir /tmp/courses-lab-checks
quarto render --profile verify
python3 scripts/check_site.py
bash scripts/check-legal-placeholders.sh
npx playwright install chromium  # add --with-deps on Linux when needed
npm run test:browser
```

Frozen execution results are a local cache and are not distributed in Git.
Ordinary `quarto render` can reuse locally frozen results; it is useful for editing but
is not fresh verification of the R calculations. Each lab produces both an
article and a Reveal.js deck. The output is `docs/`.

Run an interactive companion locally:

```bash
Rscript -e 'shiny::runApp("shiny/clt-explorer", host="127.0.0.1", launch.browser=TRUE)'
```

GitHub Pages serves the static lessons; Shiny apps require an R process or a
separately configured server. See [the maintenance record](MAINTENANCE.md) for
observed results and remaining release steps.

## URL
https://cttir.github.io/courses/

## Licence

The prose of this course is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); all code (scripts, chunks, examples) is licensed under the [MIT License](LICENSE-CODE.md).

## Citation

If you use this curriculum in your own teaching or research, please cite it as:

> Heller, R. (2026). *Biostatistics Courses: A Four-Course Programme in R and Quarto.* https://cttir.github.io/courses/

BibTeX:

```bibtex
@misc{heller2026courses,
  author       = {Heller, R.},
  title        = {Biostatistics Courses: A Four-Course Programme in R and Quarto},
  year         = {2026},
  howpublished = {\url{https://cttir.github.io/courses/}},
  note         = {CTTIR/courses; prose CC BY 4.0, code MIT}
}
```

## Use of LLM tools

Where applicable, LLM tools were used for narrowly defined, non-authorial tasks:
copyediting, prose refinement, Markdown/LaTeX formatting, boilerplate scaffolding
(such as CI configurations and build scripts), and code refactoring. Tools included
[Chat AI](https://kisski.gwdg.de/leistungen/2-02-llm-service/), the KISSKI
(GWDG) service, and self-hosted **Mistral Small (24B, Apache-2.0)** served through
a local **vLLM architecture** on an Ubuntu Linux workstation with Intel
processors and NVIDIA GPUs. The self-hosted model ran locally, with no data sent
to third parties.

All scientific claims, methodological choices, analyses, interpretations and
conclusions remain the authors' own. Where applicable, LLM-generated material
must be reviewed and revised before inclusion, and references must be verified
against their DOI, arXiv ID or ISBN.

Local software setup: vLLM with Python/PyTorch, plus R and RStudio.
