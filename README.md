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

## Build

```bash
git clone https://github.com/CTTIR/courses.git
cd courses
Rscript setup_check.R
Rscript -e 'renv::restore()'
quarto render        # builds articles + slides
quarto preview
```

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
  note         = {CTTIR/courses, MIT licence}
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

Workstation software snapshot (14 October 2026): local, OpenAI-compatible vLLM
serving with **vLLM 0.28.1rc1.dev534+g613ab20f7**, **Python 3.12.13** and
**PyTorch 2.13.0**; **R 4.6.1** and **RStudio 2026.06.0+242**. These are
workstation versions, not per-project dependency or validation requirements.
