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

Portions of these materials were prepared with assistance from large language model tooling for
narrowly defined, non-authorial tasks: copyediting, prose smoothing, Markdown/LaTeX formatting,
scaffolding of boilerplate files (CI configs, build scripts), code refactoring. The tools used were [Chat AI](https://kisski.gwdg.de/leistungen/2-02-llm-service/),
the LLM service of KISSKI (GWDG), and a self-hosted **Mistral Small (24B, Apache-2.0)** run locally via
[Ollama](https://ollama.com/) and the `ollamar` R package — local inference only, with no data sent to
third parties for the self-hosted model.

All scientific claims, methodological choices, analyses, interpretations, and conclusions are the
author's own. No LLM-generated text was incorporated without review and revision, and every reference
was verified against its DOI, arXiv ID, or ISBN.
