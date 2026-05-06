# Overview page architecture

The courses overview at `overview.qmd` is a thin Quarto page that mounts
a small ES-module set under `assets/js/overview/`. It mirrors the
architecture used by `cttir/tutorials/overview.qmd` so the two sites
share the same UX and the same code patterns.

## Pipeline

```
_data/labs.yml      ──┐
                      │
_data/courses.yml     ▼
                  scripts/build_graph.py        (Quarto pre-render)
                          │
                          ▼
                  artifacts/graph.json
                  artifacts/labs.csv
                  artifacts/cooccurrence.csv
                          │
                          ▼
                  scripts/build_related.py      (Quarto pre-render)
                          │
                          ▼
                  _includes/related/<course>__<stem>.html

      ┌──── _filters/related-include.lua  (Quarto Lua filter)
      ▼
  docs/<courseN>_*/labs/<stem>.html
                          │
                          ▼
                  scripts/build_pagefind.py     (Quarto post-render)
                          │
                          ▼
                  docs/pagefind/                (chunked WASM index)
```

## Single sources of truth

| File | What lives there |
|------|-------------------|
| `_data/courses.yml` | The 4 courses: slug, display name, colour, blurb, navigation order. Used by `build_graph.py` to validate `labs.yml` and emit the `topics` array consumed by the JS layer. |
| `_data/labs.yml` | The 80 labs: id (`courseN/lab_weekW_sessionS`), title, course slug, week, session, tags. Originally extracted from the legacy inline `LABS` array in `overview.qmd`. |

`build_graph.py` hard-fails (and aborts the render) on any drift —
unknown course slug, missing title, course in `courses.yml` with zero
labs. The JS layer never sees an inconsistent dataset.

## JS modules

```
assets/js/overview/
├── main.js          bootstrap, fetch graph.json, fan state out
├── state.js         filterState (topics + tags + query) + URL sync
├── graph.js         vis-network with opacity-based filtering
├── legend.js        course chips + tag chips with live counts
├── list.js          lab cards (week/session pill, snippet, tags)
├── search.js        Pagefind bridge, 150 ms debounce, URL ↔ id mapping
├── slider.js        dual-handle range slider (no-op on courses)
├── heatmap.js       SVG tag co-occurrence heatmap, cell-click filters
└── mobile-nav.js    visually-hidden <nav> on desktop, primary on mobile
```

Combination logic across categories: **AND**. Within a category: **OR**.
A lab passes when:
- its course is in `state.topics` (or `state.topics` is empty),
- it has at least one tag in `state.tags` (or `state.tags` is empty), and
- if a search query is active, its node id is in the Pagefind hit set.

State changes are pushed to the URL via `history.replaceState` so any
filtered view is shareable.

## CI gates

`.github/workflows/publish.yml` enforces:

- pre-render scripts succeed (front-matter + topics integrity);
- `artifacts/graph.json` is non-empty, has edges, and every course has
  at least one lab;
- `docs/pagefind/pagefind.js` and `docs/pagefind/pagefind-entry.json`
  exist after post-render.

These mirror the tutorials site's gates exactly.

## Adding a lab

1. Append a new entry under `labs:` in `_data/labs.yml` with `id`,
   `title`, `course`, `week`, `session`, `tags` (kebab-case).
2. Create the source file at
   `<courseN>_<dirname>/labs/lab_weekW_sessionS.qmd`.
3. Run `quarto render` (CI does the same).
4. The Lua filter injects a static "Related labs" section into the
   page automatically if the lab has ≥ 2 shared tags with another lab.

## Adding or renaming a course

Edit `_data/courses.yml`. The directory on disk uses the *long* name
(e.g. `course3_design_causal/`); the slug used in the JS layer is the
short form (`course3`). The mapping is hard-coded in
`scripts/build_graph.py::COURSE_DIR`,
`scripts/build_related.py::COURSE_DIR`, and
`assets/js/overview/search.js::DIR_TO_COURSE`. Update all three when
adding a course.

## Out of scope for this rebuild

- Lab body content (untouched).
- Slides, cheatsheets, appendices (no overview integration).
- Per-lab labels axis (the `_data/labs.yml` schema reserves no `labels`
  field; `graph.json` ships `labels: []`). Add a labels block to
  `labs.yml` and extend `build_graph.py` if a third filter axis becomes
  useful.
