#!/usr/bin/env python3
"""Build the Pagefind static search index over docs/.

Quarto `post-render` step (wired in _quarto.yml). Cross-platform via npx.
Index scope: lab detail pages only — courseN_*/labs/*.html. The four
course-index files are stamped with `data-pagefind-ignore="all"` so
they don't dilute search relevance with their auto-listing of all labs.

Soft-skip when Node is unavailable so a `quarto preview` on a Node-less
machine still completes; CI fails hard via the verify-gate in publish.yml.
"""
from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"


def main() -> int:
    if not DOCS.exists():
        print(f"build_pagefind: skipped — {DOCS.relative_to(ROOT)} does not exist yet")
        return 0

    npx = shutil.which("npx") or shutil.which("npx.cmd")
    if not npx:
        print(
            "build_pagefind: WARNING — `npx` not found on PATH. "
            "Skipping search index build. Install Node.js to enable.",
            file=sys.stderr,
        )
        return 0

    skipped = _ignore_course_indexes()
    if skipped:
        print(f"build_pagefind: marked {skipped} course-index pages with data-pagefind-ignore")

    cmd = [
        npx, "-y", "pagefind@latest",
        "--site", str(DOCS),
        "--glob", "course*/labs/*.html",
        "--output-subdir", "pagefind",
    ]
    print("build_pagefind: " + " ".join(cmd))
    result = subprocess.run(cmd, cwd=ROOT)
    if result.returncode != 0:
        print(f"build_pagefind: ERROR — pagefind exited {result.returncode}", file=sys.stderr)
        return result.returncode

    index_root = DOCS / "pagefind"
    if not (index_root / "pagefind.js").exists():
        print(
            f"build_pagefind: ERROR — expected {index_root.relative_to(ROOT)}/pagefind.js "
            f"after build, but it was not created",
            file=sys.stderr,
        )
        return 1
    print(f"build_pagefind: OK -> {index_root.relative_to(ROOT)}/")
    return 0


_BODY_OPEN_RE = re.compile(r"<body\b(?![^>]*\bdata-pagefind-ignore\b)([^>]*)>")


def _ignore_course_indexes() -> int:
    """Insert data-pagefind-ignore='all' into each course-index <body>.

    Idempotent — files that already carry the attribute are left alone.
    Returns the number of files actually rewritten this pass.
    """
    n = 0
    for index in DOCS.glob("course*/index.html"):
        text = index.read_text(encoding="utf-8", errors="replace")
        new, count = _BODY_OPEN_RE.subn(
            r'<body data-pagefind-ignore="all"\1>', text, count=1
        )
        if count:
            index.write_text(new, encoding="utf-8")
            n += 1
    return n


if __name__ == "__main__":
    sys.exit(main())
