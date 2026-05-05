# VG Wort Zählmarke distribution — `distribute_vgwort.py`

This script walks every `.qmd` in the current Quarto repo, classifies each one, and pastes one unused VG Wort Zählmarke into every CONTENT page. The xlsx inventory at `F:\Dropbox\Arbeit\Firma\boulingua\VGWort - rh\zaehlmarken_combined.xlsx` is the single source of truth and is **shared across all repos** (`tutorials/`, `courses/`, …). The script is idempotent and safe to run again — already-marked pages are reconciled, never double-marked.

## Hard rules

- Each marker is consumed exactly once across all repos.
- The xlsx is updated atomically alongside each qmd write.
- Dry-run is the default; `--apply` is required to write anything.
- `--apply` refuses to run if `git status --porcelain` is non-empty.
- On `--apply`, the xlsx is backed up to `<original>.bak.<timestamp>` before any write.
- If a Dropbox `*CONFLICT*` copy exists next to the xlsx, the script aborts.

## Prerequisites

```powershell
pip install openpyxl pyyaml
```

## Workflow

Run from the repo root (e.g. `C:\Users\raban\Documents\GitHub\courses`).

### 1. Dry-run on a small slice first

```powershell
python scripts\distribute_vgwort.py `
    --xlsx "F:\Dropbox\Arbeit\Firma\boulingua\VGWort - rh\zaehlmarken_combined.xlsx" `
    --only "course1_foundations/**"
```

Review the discovery table and the "WOULD WRITE" lines. Confirm:

- The CONTENT / META / INCLUDE / DRAFT / INDEX-ONLY classifications look right.
- No pages you intend to mark are mis-classified.
- The number of "WOULD WRITE" entries matches your expectation.

### 2. Apply on the same slice

```powershell
python scripts\distribute_vgwort.py `
    --xlsx "F:\Dropbox\Arbeit\Firma\boulingua\VGWort - rh\zaehlmarken_combined.xlsx" `
    --only "course1_foundations/**" `
    --apply
```

Then `git diff` to inspect the inserted snippets. Each one looks like:

```
::: {.vgwort-pixel}
```{=html}
<!-- VG Wort Zählmarke — public ID: 00102b38dac145b2a64f963f7bc63982 -->
<img src="https://vg09.met.vgwort.de/na/00102b38dac145b2a64f963f7bc63982" ... />
```
:::
```

### 3. Full dry-run, then full apply

```powershell
python scripts\distribute_vgwort.py `
    --xlsx "F:\Dropbox\Arbeit\Firma\boulingua\VGWort - rh\zaehlmarken_combined.xlsx"

python scripts\distribute_vgwort.py `
    --xlsx "F:\Dropbox\Arbeit\Firma\boulingua\VGWort - rh\zaehlmarken_combined.xlsx" `
    --apply
```

### 4. Commit

```powershell
git add -A
git commit -m "Distribute VG Wort Zählmarken across content pages"
```

## Per-page opt-out

Add this to a page's YAML frontmatter to permanently exclude it (it will be classified as META):

```yaml
vgwort: false
```

## Rollback

- **qmd changes:** `git checkout -- .` (works because `--apply` requires a clean tree, so any inserted snippets are uncommitted on first run).
- **xlsx:** restore the most recent `zaehlmarken_combined.xlsx.bak.<timestamp>` next to the original.

```powershell
# Roll back qmd:
git checkout -- .

# Roll back xlsx (replace timestamp):
Copy-Item "F:\Dropbox\Arbeit\Firma\boulingua\VGWort - rh\zaehlmarken_combined.xlsx.bak.20260505_120000" `
          "F:\Dropbox\Arbeit\Firma\boulingua\VGWort - rh\zaehlmarken_combined.xlsx" -Force
```

## Classifications (what gets marked)

| Class | Marked? | Examples / rule |
|---|---|---|
| CONTENT | Yes | normal tutorial / unit pages, including section `index.qmd` with ≥ 200 chars of prose |
| META | No | `about.qmd`, `impressum.qmd`, the site-root `index.qmd`, anything in `about/`/`meta/`/`legal/`, frontmatter `vgwort: false` |
| INCLUDE | No | filenames starting with `_` (Quarto include partials) |
| DRAFT | No | frontmatter `draft: true` |
| INDEX-ONLY | No | section `index.qmd` files with < 200 chars of prose (pure ToC) |

Character count is reported for every CONTENT page but is **not** a gate — every CONTENT page gets a marker regardless of length. Pages below 1,800 chars are flagged in the summary as "consider expanding for Hauptausschüttung eligibility".

## Multi-repo use

This script is designed to be run in `tutorials/`, then `courses/`, then any future Quarto repo, all pointing at the same `--xlsx`. Each run only consumes markers for that repo's CONTENT pages and updates the shared xlsx atomically. Idempotency means re-running in any repo is always safe.

## Anomalies that abort the run

- **Foreign marker** — a qmd contains a public ID that is not in the xlsx. (Phase 2 logs and exits non-zero.)
- **Dropbox conflicted copy** — abort and reconcile manually.
- **Available pool too small** — refuses to partially allocate.
- **Dirty git tree on `--apply`** — commit or stash first.
