# Legal pages — Pflege- und Build-Hinweise

- `impressum.qmd`, `datenschutz.qmd`, `haftungsausschluss.qmd`
- Header oben rechts: **Rechtliches** Dropdown
- Footer: dedizierte Linkgruppe inkl. Kontakt-mailto

## Plausible Analytics

Selbst gehostet auf `analytics.hellebo.de` (Server in
Deutschland), eingebunden via `_includes/plausible.html` (in
`_quarto.yml` → `format.html.include-in-header`).

## VG Wort Standard-Zählpixel

Pandoc-Lua-Filter `scripts/vgwort.lua`, in `_quarto.yml` unter
`filters:` aktiviert.

### Workflow pro zählpflichtiger Kursseite

1. Token aus [VG Wort T.O.M.](https://tom.vgwort.de/) ziehen.
2. Mindestens **1.500 Zeichen** Text.
3. In der YAML-Frontmatter:
   ```yaml
   ---
   title: "..."
   vgwort_pixel: "vg08.met.vgwort.de/na/<32-hex-token>"
   ---
   ```
4. Übersichten, Listings, Rechtliches, 404 bleiben pixelfrei.

## CI-Guard

```bash
bash scripts/check-legal-placeholders.sh
```
