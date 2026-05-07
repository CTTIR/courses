# Recon — landing avatar + linked title (branch `feat/landing-avatar`)

Mirrors `CTTIR/tutorials` PR `feat/landing-avatar` (recon-only at HEAD —
no merged implementation yet, so class names defined here are the source
of truth and tutorials will copy these on merge).

## Title rendering surface

`index.qmd` carries:

- YAML frontmatter `title: "Biostatistics Courses"` and
  `pagetitle: "Biostatistics Courses"`. No `title-block-style: none` —
  Quarto renders its default title block from `title:`.
- An explicit body H1 inside `::: {.hero}`:
  `# A four-course ladder, end to end`.

**Live `<title>` reads `Biostatistics Courses – #courses`** (Quarto's
`<title>` tag = page `title` + " – " + site `title`). The page H1 the
user wants linked to the courses index is therefore the **YAML-driven
"Biostatistics Courses"** title block, NOT the body hero H1.

This differs from the tutorials site, where `title-block-style: none`
suppresses the YAML title block and the body H1 (`# #tutorials`) is the
sole rendered H1. Here we have two H1s today: the title block
("Biostatistics Courses") and the hero body ("A four-course ladder,
end to end"). The hero body line is functionally a subtitle.

## Decision

Per the prompt's branching instructions ("If the H1 comes from page YAML
`title:` — remove `title:` from the YAML and write the H1 explicitly in
the body as a Markdown link"):

1. **Remove** `title:` from `index.qmd` YAML. Keep `pagetitle:` so the
   browser `<title>` tag stays `Biostatistics Courses – #courses`.
2. **Add** an explicit body H1 above the existing `::: {.hero}` block:
   `# [Biostatistics Courses](https://cttir.github.io/courses/)`.
3. **Insert** the avatar `<a><img></a>` block immediately above that
   linked H1. Avatar links to `https://cttir.github.io/website/`.
4. **Leave** the hero block intact (kicker + "A four-course ladder, end
   to end" + lead). It will render as a body H1 below the new linked
   H1; this preserves the current visual hierarchy. The prompt's
   deliverables call this line a "H2/subtitle" but explicitly says
   "still renders correctly below the H1" — i.e. do not modify it.

Resulting top of `index.qmd`:

```markdown
---
pagetitle: "Biostatistics Courses"
toc: false
---

<a href="https://cttir.github.io/website/" class="ctir-avatar-link" aria-label="CTIR home">
  <img src="https://cttir.github.io/website/images/cttir-logo.png"
       alt="CTIR — Computational Trauma and Tissue Injury Research"
       class="ctir-avatar" />
</a>

# [Biostatistics Courses](https://cttir.github.io/courses/)

::: {.hero}
::: {.kicker}
OPEN CURRICULUM · R · QUARTO · MIT
:::
# A four-course ladder, end to end
...
```

## Existing navbar `#courses` link

Defined in `_quarto.yml` at `website.title: "#courses"` and
`website.navbar.title: "#courses"`. Quarto renders this as the
`.navbar-brand` and auto-links it to the site root. Untouched.

## CSS surface

Themes wire `assets/light.scss` and `assets/dark.scss`, both of which
import `assets/_shared.scss` (hero/kicker styles already live there).
New `.ctir-avatar` / `.ctir-avatar-link` rules go into `_shared.scss`
adjacent to the hero block (~line 170) so they apply in both themes.
Class names match what the tutorials sister PR will use, so the two
sites stay visually consistent.

## Cross-site image

Source: `https://cttir.github.io/website/images/cttir-logo.png` — lives
in `CTTIR/website` (Hugo). Referenced live; **not** copied into this
repo. Update at the source to propagate to both sister sites.

## Out of scope

- Navbar, footer, page-footer left/center/right.
- Any course content, hero subtitle, card grid, or schedule prose.
- The four course landing pages and their titles.
- Any title-block partial override.
