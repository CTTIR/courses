#!/usr/bin/env python3
"""Check existing legal output for unresolved placeholders."""
import os
from pathlib import Path
import sys

root = Path(os.environ.get('BUILD_DIR', 'docs'))
if not root.is_dir():
    raise SystemExit(f'Build directory {root} is missing; render first')
placeholders = ('{{CONTACT_EMAIL_HELLER}}', '{{CONTACT_EMAIL_LEBOULANGER}}', '{{SITE_DOMAIN}}')
legal_names = ('impressum', 'datenschutz', 'haftungsausschluss', 'privacy', 'imprint', 'disclaimer')
failures = []
for path in root.rglob('*'):
    if not path.is_file() or path.suffix not in ('.html', '.js', '.json', '.css', '.txt'):
        continue
    text = path.read_text(encoding='utf-8', errors='replace')
    markers = list(placeholders)
    if path.name.startswith(legal_names) or any(part in ('legal', 'rechtliches') for part in path.parts):
        markers.extend(('TODO', 'FIXME'))
    for marker in markers:
        if marker in text:
            failures.append(f'{path}: {marker}')
if not (root / 'impressum.html').is_file():
    failures.append('Missing impressum.html')
if failures:
    print('\n'.join(failures), file=sys.stderr)
    raise SystemExit(1)
print(f'Legal placeholder check passed: {root}')
