#!/usr/bin/env python3
"""Per-lab "Related labs" partials.

Reads artifacts/graph.json (run scripts/build_graph.py first) and emits
_includes/related/<courseN>__<lab-stem>.html. The Lua filter at
_filters/related-include.lua appends the matching partial to each lab
page at render time, so /labs/lab_weekW_sessionS.html ships its
"Related labs" section as static HTML with zero JS request.

Ranking: edge-weight sum + small same-course bonus.
"""
from __future__ import annotations

import html
import json
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GRAPH = ROOT / "artifacts" / "graph.json"
OUT = ROOT / "_includes" / "related"

K = 3
COURSE_BONUS = 0.05

# `course1` slug maps to the long directory name on disk.
COURSE_DIR = {
    "course1": "course1_foundations",
    "course2": "course2_regression",
    "course3": "course3_design_causal",
    "course4": "course4_ml_highdim",
}


def main() -> int:
    if not GRAPH.exists():
        print(f"build_related: {GRAPH.relative_to(ROOT)} not found — run build_graph.py first",
              file=sys.stderr)
        return 1

    data = json.loads(GRAPH.read_text(encoding="utf-8"))
    nodes = data["nodes"]
    edges = data["edges"]
    topic_label = {t["id"]: t["label"] for t in data.get("topics", [])}

    adj: dict[str, list[tuple[str, int]]] = defaultdict(list)
    for e in edges:
        adj[e["source"]].append((e["target"], e["weight"]))
        adj[e["target"]].append((e["source"], e["weight"]))

    by_id = {n["id"]: n for n in nodes}

    OUT.mkdir(parents=True, exist_ok=True)
    written = 0
    skipped = 0
    for self_node in nodes:
        scored: dict[str, float] = {}
        for nbr, w in adj.get(self_node["id"], []):
            scored[nbr] = scored.get(nbr, 0.0) + float(w)

        ranked = sorted(
            scored.items(),
            key=lambda kv: (
                -(kv[1] + (COURSE_BONUS if by_id[kv[0]]["topic"] == self_node["topic"] else 0.0)),
                kv[0],
            ),
        )
        top = [by_id[i] for i, _ in ranked[:K]]
        if not top:
            partial_path(self_node["id"]).write_text("", encoding="utf-8")
            skipped += 1
            continue

        partial_path(self_node["id"]).write_text(render(self_node, top, topic_label), encoding="utf-8")
        written += 1

    print(
        f"build_related: wrote {written} partials, "
        f"{skipped} labs had no neighbours -> {OUT.relative_to(ROOT)}/"
    )
    return 0


def partial_path(node_id: str) -> Path:
    # node_id is "courseN/lab_weekW_sessionS"; flatten with __ separator.
    return OUT / (node_id.replace("/", "__") + ".html")


def render(self_node: dict, top: list[dict], topic_label: dict[str, str]) -> str:
    items = []
    for n in top:
        topic_disp = topic_label.get(n["topic"], n["topic"])
        # Lab pages live at <coursedir>/labs/<stem>.html, so peer labs
        # in the same course are "./<stem>.html" and peers in a
        # different course are "../../<otherdir>/labs/<stem>.html".
        target_dir = COURSE_DIR.get(n["topic"], n["topic"])
        url = f"../../{target_dir}/labs/{n['id'].split('/', 1)[1]}.html"
        items.append(
            '<div class="related-item">'
            f'<span class="topic">{html.escape(topic_disp)}</span>'
            f'<a href="{html.escape(url, quote=True)}">{html.escape(n["title"])}</a>'
            "</div>"
        )

    return (
        '<section class="related-tutorials" data-render="static">\n'
        "<h2>Related labs</h2>\n"
        f'<div class="related-list">{"".join(items)}</div>\n'
        '<p class="network-link"><a href="../../overview.html">Explore the full label network &rarr;</a></p>\n'
        "</section>\n"
    )


if __name__ == "__main__":
    sys.exit(main())
