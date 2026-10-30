#!/usr/bin/env python3
"""Verify the complete built curriculum, downloads, and local link targets."""
import json
from html.parser import HTMLParser
from pathlib import Path
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs'

class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
    def handle_starttag(self, tag, attrs):
        for name, value in attrs:
            if name in ('href', 'src') and value:
                self.links.append(value)

def main():
    errors = []
    sources = sorted(ROOT.glob('course*/labs/lab_*.qmd'))
    if len(sources) != 80:
        errors.append(f'Expected 80 labs; found {len(sources)}')
    for source in sources:
        rel = source.relative_to(ROOT)
        for target in (rel.with_suffix('.html'),
                       rel.with_name(rel.stem + '_slides.html'),
                       Path(rel.parts[0]) / 'code' / (rel.stem + '.R')):
            output = DOCS / target
            if not output.is_file() or not output.stat().st_size:
                errors.append(f'Missing output: {target}')
        download = DOCS / rel.parts[0] / 'code' / (rel.stem + '.R')
        original = ROOT / rel.parts[0] / 'code' / (rel.stem + '.R')
        if download.is_file() and download.read_bytes() != original.read_bytes():
            errors.append(f'Stale script download: {download.relative_to(DOCS)}')
    for name in ('artifacts/graph.json', 'artifacts/labs.csv', 'artifacts/cooccurrence.csv',
                 'pagefind/pagefind.js', 'pagefind/pagefind-entry.json',
                 'pagefind/licenses/LICENSE', 'LICENSE-CODE.md'):
        if not (DOCS / name).is_file() or not (DOCS / name).stat().st_size:
            errors.append(f'Missing artifact: {name}')
    checked = 0
    for page in DOCS.rglob('*.html'):
        parser = Links(); parser.feed(page.read_text(encoding='utf-8'))
        for link in parser.links:
            url = urlsplit(link)
            if url.scheme or url.netloc or not url.path:
                continue
            path = unquote(url.path)
            # A site-root link may carry the GitHub Pages project prefix.
            if path.startswith('/courses/'):
                path = path[len('/courses/'):]
                target = DOCS / path
            elif path.startswith('/'):
                target = DOCS / path.lstrip('/')
            else:
                target = page.parent / path
            checked += 1
            if not target.exists():
                errors.append(f'{page.relative_to(DOCS)} -> {link}')
    if errors:
        print('\n'.join(sorted(set(errors))), file=sys.stderr)
        return 1
    print(f'Complete: 80 articles, 80 slides, 80 matching scripts; {checked} local links checked')
    return 0

if __name__ == '__main__':
    sys.exit(main())
