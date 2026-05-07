# Recon — site rename "Biostatistics Courses" → "#courses" (branch `chore/rename-to-hash-courses`)

Brings the H1 / page title surfaces in line with the navbar (`#courses`)
and the sister sites (`#tutorials`, `#ressources`).

## Rename targets (site name / page H1 / branding surfaces)

| File | Line | Current | New |
|------|------|---------|-----|
| `index.qmd` | 2 | `pagetitle: "Biostatistics Courses"` | `pagetitle: "#courses"` |
| `index.qmd` | 12 | `# [Biostatistics Courses](https://cttir.github.io/courses/)` | `# [#courses](https://cttir.github.io/courses/)` |
| `_quarto.yml` | 63 | `left: "Biostatistics Courses · MIT"` (page-footer) | `left: "#courses · MIT"` |
| `README.md` | 1 | `# Biostatistics Courses` | `# #courses` |
| `course{1..4}*/labs/*.qmd` | 3 (×80) | `subtitle: "Course N — Biostatistics Courses"` | `subtitle: "Course N — #courses"` |

The lab-page `subtitle:` field functions as a page-level brand line
("which series does this lab belong to?") — same role as the navbar
brand, so it is in scope.

`_quarto.yml` `website.title`, `website.navbar.title`, and the navbar
`#courses` brand are **already** `#courses`. Untouched.

## Keep (descriptive / citation prose — NOT site-title surfaces)

| File | Line | Context |
|------|------|---------|
| `about.qmd` | 130 | Suggested citation: `Heller, R. (2026). *Biostatistics Courses: A Four-Course Programme...*` |
| `about.qmd` | 138 | BibTeX `title = {Biostatistics Courses: A Four-Course Programme in R and Quarto}` |
| `README.md` | 45 | Same suggested citation block |
| `README.md` | 52 | Same BibTeX entry |

These cite the work by its formal descriptive title. Renaming a BibTeX
`title` field to `#courses` would be inappropriate (citations need a
human-readable, typeset-safe title). They describe the work, not the
site brand. Out of scope per the prompt's "do not rewrite body copy
that describes the curriculum" rule.

Body prose in `index.qmd` ("this site hosts a complete, opinionated
biostatistics programme…") already uses lowercase "biostatistics" as
descriptive English — no hits for the cased phrase "Biostatistics
Courses" outside the rows above.

`PLAN.md` historical recon entries (lines 11–60) are stale by design —
this very file overwrites them.

## Out of scope

- Body prose mentioning "biostatistics" (descriptive).
- Citations in `about.qmd` and `README.md`.
- Course landing pages and per-lab `title:` fields (not "Biostatistics
  Courses"; out of the rename scope).
- The avatar / linked-H1 from PR #1 — link target preserved, only the
  visible text inside `# [...](...)` changes.
