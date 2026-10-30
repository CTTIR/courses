# Legal pages — Pflege- und Build-Hinweise

`impressum.qmd` ist die vorhandene Rechts- und Kontaktseite. Navigation und
Footer verweisen direkt darauf. Separate Datenschutz- und Haftungsseiten oder
ein VG-Wort-Filter sind in diesem Projekt derzeit nicht implementiert.

## Einbindungen

`_includes/plausible.html` bindet die selbst gehostete Analytics-Instanz
`analytics.hellebo.de` ein. `_quarto.yml` lädt Schriftarten von Google Fonts;
`overview.qmd` lädt vis-network von unpkg.com. Diese externen Dienste und die
Angaben im Impressum sind vor einer Änderung der Veröffentlichung durch den
Betreiber abzugleichen. Dieses Dokument bestätigt keine rechtliche Prüfung.

## Lizenzen und Prüfung

Kurstexte: CC BY 4.0. Code: MIT (`LICENSE-CODE.md`). Bestehende Quellen- und
Danksagungen bleiben erhalten. Nach dem Build:

```bash
bash scripts/check-legal-placeholders.sh
python3 scripts/check_site.py
```

Diese technischen Prüfungen erkennen Platzhalter und fehlende lokale Ziele;
sie ersetzen keine inhaltliche oder rechtliche Prüfung der Angaben.
