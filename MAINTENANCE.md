# Maintenance review — 30 October 2026

## Hosted follow-up — 3 November 2026

The first Linux run after publication (`41604874549`, source `c20e71b`)
stopped during `renv` restoration: the locked igraph 2.3.4 binary could not
load `libglpk.so.40`. This was an omitted native prerequisite, before any
lesson validation ran. Add `libglpk-dev` to the existing native installation
step before restoration and provide the same complete apt command in the
first-use guide. Preserve the lockfile, all lesson tests and render gates.

Observed local evidence: Ubuntu 24.04 aarch64 apt resolves `libglpk-dev` to
`libglpk40` (5.0-1build2); the installed library loads and `glp_version()`
returns 5.0. This checks the missing runtime library, not the full hosted
Ubuntu environment. The updated guide renders successfully with Quarto
1.10.19 and Pagefind indexes all 80 lab pages. Seven JavaScript and six Python
tests pass; the complete-site checker finds all 80 articles, 80 slide decks
and 80 scripts and checks 7,437 local links. Actionlint and whitespace checks
pass. Lesson calculations are unchanged and were not recomputed for this
native-prerequisite repair. Exact-head hosted restoration, full recomputation
and deployment must be observed separately after pushing.

## Original audit

Scope: the four-course curriculum, 80 executable labs and companion scripts,
12 local Shiny apps, website navigation/search, and the Pages build. Baseline:
`05970afe487e19b2a0a97917c59b11aeaef2ea01`. Work is isolated from the original
checkout. Publication requires a separate authorized push and successful CI.

## Evidence and release criteria

Confirmed baseline release blockers (repaired):

- `renv.lock` has 61 package records with no versions. The setup checker installs
  unpinned packages and can exit successfully after failure; documented restoration
  is therefore not reproducible.
- Course 4 week 1 session 1 promises .632+ but calculates .632 with a bootstrap
  training error instead of the original-sample apparent error.
- `shiny/regularization-path/app.R` converts coefficient labels such as `s0` to
  integers, losing the lambda values; choosing more signals than predictors also
  breaks matrix multiplication.
- `shiny/cv-vs-nested/app.R` claims an inner CV loop but selects by correlation;
  its reference line is irreducible variance, not the fitted model's true error.
- `shiny/decision-curves/app.R` treats an uncalibrated score as a risk probability.
- The overview search resolves a relative dynamic import against its module
  directory and has no protection against out-of-order query responses.
- The Pages workflow reuses frozen calculations, has no pull-request gate, and
  indexes an unpinned Pagefind release. Its output checks do not verify all labs.

Further confirmed scientific defects found during the broader trace:

- Course 4 week 3 session 5 treats early censoring as no event, interpolates
  a step baseline hazard, and mismatches its Cox centering. Its stated loss of
  calibration is not implied by covariate shift alone. Repair: IPCW Brier/AUC,
  cohort KM null risk and calibration, matched centering, evidence-led reporting.
- Course 3 week 3 session 1 can create exposure intervals beyond administrative
  follow-up. Repair: cap exposure classification and intervals at observed time.
- Course 3 week 3 sessions 4–5 mislabel adjusted regression, use known propensity
  scores without explaining that distinction, and show ordinary WLS confidence
  intervals for IPTW. Repair: estimated scores, precise estimand labels and point
  estimates, with whole-subject refitting described for uncertainty.
- `shiny.qmd` advertises deployed links on a placeholder domain. Repair: usable
  source/local-run links and an explicit statement that hosting is unconfigured.

Other repairs: validate graph IDs and source files; handle empty/invalid DAGs and
one-class logistic samples visibly; align missingness and mixture simulations
with their labels; synchronize onboarding and licence/maintenance documentation.

Baseline observations: graph generation succeeds (80 labs, 1,010 edges, four
courses). A clean minimal website with the same two-format declaration produces
both HTML and Reveal.js under `quarto render`; that README claim is correct.
Existing hosted CI success and checked-in output are not evidence of fresh R
execution under the current dependencies.

## Roadmap

1. **Essential repairs.** Correct the calculations and interaction defects above;
   protect them with numerical, malformed-input, and asynchronous-search tests.
   Acceptance: reference calculations agree, supported app inputs produce usable
   output, and failures display actionable messages rather than stale results.
2. **Dependable first use.** Record actual render dependencies and versions;
   provide explicit project-library restoration and a read-only setup check.
   Acceptance: exact documented commands and a clean-library restore work, with
   nonzero exit status for missing requirements. Optional unevaluated sketches
   stay explicitly separate from the runnable curriculum.
3. **Release verification.** Execute all labs afresh, render articles and slides,
   validate local links and the search index, exercise the 12 apps, and add the
   same checks to pull-request CI without deployment permissions.
   Acceptance: 80 articles, 80 slides, 80 downloadable scripts, working search,
   meaningful regression checks, and no unresolved execution failures.
4. **Deferred.** Additional courses, hosted Shiny infrastructure, and broad visual
   redesign are outside this maintenance release. External instructor review
   remains useful for pedagogy; local checks do not establish learning outcomes.

## Validation and handover

The three maintenance milestones above are complete locally. No hosted build,
Pages deployment, or instructor acceptance is claimed.

### Additional findings and completed changes

All rows below were confirmed in source or direct execution, rather than
inferred from a missing test. Articles and downloadable scripts were updated
together; affected handouts were rebuilt.

| Severity | Location / evidence | User impact and completed action |
| --- | --- | --- |
| High | Course 4, W4/S1: scalar `ifelse()` selected one gene effect | Every gene was changed while the lesson claimed ten changed genes. Apply the full effect vector; expose failed/warned fits; distinguish recovery, null-gene flagging and false-discovery proportion. |
| High | Course 3, W1/S2–4; Course 1 contrasts | Per-protocol and as-treated populations were conflated; estimate/interval directions and factorial references were inconsistent. Define populations and contrasts explicitly and verify them against independent means. |
| High | Course 3, W1/S5 downloadable script | All-missing placeholder responses prevented `makeLmer()` from running. Supply the finite placeholder used in the article; the 50-replicate teaching simulation completes without fit warnings/errors. |
| Medium | Course 2, W3/S1 | Plotting the fitted logit against its own predictor could not diagnose nonlinearity. Use empirical binned logits and a spline comparison, with appropriate interpretation. |
| Medium | Course 3, W4/S3 and W4 handout | Default P-scores were labelled SUCRA. Request SUCRA explicitly with 10,000 simulations. |
| Medium | Course 3 observational/missing-data lessons | Cumulative case-control sampling was labelled risk-set sampling; missingness and IPTW claims exceeded the example. Correct the design and estimands; show estimates without unsupported confidence intervals or guaranteed balance. |
| Medium | Overview summary and shared URLs | Summary updates removed the reset button; the autocomplete could cover it; date parameters could hide the entire catalogue. Preserve a separate summary span, put reset above the dropdown, and bound/reset filter state. |
| Medium | Graph/search unavailable | Reset threw when the graph CDN failed, and search failures could retain stale results. Preserve browsing/reset and show a recoverable search message. |
| Medium | Shiny companions | Repair lambda mapping, actual nested selection, calibrated simulated risks, independent mixture membership, target missingness, DAG/one-class validation, diagnostic expected counts and SIR labels. |
| Medium | Dependency/build pipeline | Replace unversioned records with 332 versioned records and renv activation; require fresh PR builds, validate all downloads/links, pin Pagefind/Playwright and preserve runtime/code licence notices. |

Old tracked `_freeze/` results were removed from this isolated branch; they
remain in Git history and the original checkout. New frozen results are a local
ignored editing cache. The verification profile bypasses both freeze and chunk
cache and stops on execution errors. Fresh `docs/` replaces the old generated
site, including both lesson formats, the handouts, search and matching scripts.
PDFs are explicitly treated as binary Git files.

### Observed verification

- macOS ARM64, R 4.6.1, Quarto 1.10.19, Node 24.22.1; Python 3.9.6 and
  3.15.0 checks. A separate empty project library restored using the package
  cache and matched all **332 exact DESCRIPTION versions**. This verifies
  cached restoration on this Mac, not a fresh Linux/Windows compilation.
- All **80 standalone scripts** completed in separate R processes and empty
  working directories with the restored library (166 seconds total execution).
- **132 R assertions**, **7 Node tests**, and **6 Python tests** passed.
  The R suite had no failures, warnings or skips, and exercised every output
  of all 12 apps plus numerical references and failure paths.
- A fresh render processed **119 Quarto inputs**. Subsequent targeted renders
  incorporated the final overview, onboarding and handout edits. Output:
  **80 articles, 80 slide decks, 80 byte-matching R downloads, 16 PDFs / 32 pages**.
  All **7,437 local links** resolve. Search indexes exactly 80 articles.
- Browser checks exercised the real search index under both root and Pages
  subpath URLs, keyboard filtering, reset, empty search, mobile links, slide
  navigation and unavailable graph/search assets. The committed browser test
  also passes locally and is included in CI. Three live Shiny apps passed
  additional browser interactions, including invalid-DAG recovery.
- PDF text bounds were checked on every page; representative handouts and
  desktop/mobile/app screenshots were visually inspected. This is not a full
  accessibility certification or an instructor review of every statement.
- The setup checker succeeds for the recorded environment and exits 1 when
  command-line requirements are absent. It installs nothing. Workflow syntax,
  legal-placeholder checks and npm audit pass (zero npm advisories reported).
  This does not establish the absence of vulnerabilities in every R dependency.

Authored source whitespace checks pass. The vendored renv activation script
retains upstream whitespace, and generated HTML retains the trailing alignment
padding emitted by R tables and `sessionInfo()`; those generated files are not
described as whitespace-clean. PDF byte content is retained unchanged after rendering.

Two script warnings are retained and explained: the missing-data illustration
omits 12 unavailable plot rows; the illustrative per-gene RNA-seq fits report
64 warned/failed fits and exclude them from inference. The RNA-seq lesson now
explicitly says that this small-sample Wald demonstration is not a validated
analysis pipeline. Optional unevaluated Bayesian/omics sketches were not run.

### First use and release step

Follow the exact prerequisites and commands in `README.md` and `get_started.qmd`:
`Rscript -e 'renv::restore(prompt=FALSE)'`, `npm ci`, `Rscript setup_check.R`,
then `quarto preview`. The renv autoloader bootstraps the recorded renv version.
Use the README qualification commands before release. Native source builds
require the documented compiler/system libraries (including FFTW and CMake).

The static site can also be served directly with `python3 -m http.server 8080 --directory docs`. Local Shiny use requires a separate R process,
for example `Rscript -e 'shiny::runApp("shiny/clt-explorer")'`.

Next publication action: review the local maintenance commits, authorize the
intended merge/push, then require the hosted validation job to pass before its
Pages deployment. That new hosted job has not run. Deployment credentials,
Pages settings and the operator's legal/contact disclosures require owner
confirmation in the publication environment. No deployed Shiny service is
configured or claimed.

Deferred: independent pedagogical/scientific review before teaching or research
adoption, hosted Shiny infrastructure, optional external-data/Bayesian examples,
a full accessibility assessment, and broader course expansion. These are not
represented as completed by passing software checks.

### Reference checks

- [Quarto execution and freeze](https://quarto.org/docs/projects/code-execution.html)
- [renv CI restoration](https://rstudio.github.io/renv/articles/ci.html)
- [Efron and Tibshirani, .632+ bootstrap](https://sites.stat.washington.edu/courses/stat527/s13/readings/EfronTibshirani_JASA_1997.pdf)
- [Survival package reference](https://www.stat.ethz.ch/CRAN/web/packages/survival/refman/survival.html)
- [Graf et al., censored prediction error](https://pubmed.ncbi.nlm.nih.gov/10474158/)
- [netmeta reference: P-scores and SUCRA](https://guido-s.r-universe.dev/netmeta/doc/manual.html)
- [Pagefind browser API](https://pagefind.app/docs/search-config/)
