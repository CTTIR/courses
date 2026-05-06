#!/usr/bin/env python3
"""Build artifacts/graph.json from _data/{labs,courses}.yml.

Mirrors the data shape used by the tutorials site so the same JS
overview module ports across with minimal change. Differences:
  - Each "topic" here is a course (course1..course4).
  - There is no separate label axis; tags carry the entire taxonomy.
  - Each course has an `href` to its index page so the JS list can
    surface a "Browse course X" link alongside individual labs.

Hard-fails (exit 1) on:
  - Missing _data/labs.yml or _data/courses.yml
  - A lab whose `course` value is not declared in courses.yml
  - A course in courses.yml with zero labs
  - Empty result set
"""
from __future__ import annotations

import csv
import json
import re
import sys
from collections import defaultdict
from itertools import combinations
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LABS_YAML = ROOT / "_data" / "labs.yml"
COURSES_YAML = ROOT / "_data" / "courses.yml"
ARTIFACTS = ROOT / "artifacts"

SHARED_TAG_THRESHOLD = 2

# Filesystem-name override per course slug. labs/<lab>.qmd live under
# the *long* directory names (course1_foundations/, …) but the JS layer
# uses the short `course1` slug so URLs stay short.
COURSE_DIR = {
    "course1": "course1_foundations",
    "course2": "course2_regression",
    "course3": "course3_design_causal",
    "course4": "course4_ml_highdim",
}

# Cross-cutting "method-family" tags, derived from each lab's title +
# its hand-tagged keywords. Each entry is a single derived tag with a
# list of regex patterns; if any pattern matches the haystack the tag
# is added. This is the same mechanism the tutorials site uses to make
# the graph dense across topics. Mirrors that vocabulary so a viewer
# moving between the two sites recognises the cluster names.
MID_LEVEL_TAGS: dict[str, list[str]] = {
    "regression-methods": [
        r"\bregression\b", r"\bglm\b", r"\bglmm\b", r"\bgam\b",
        r"\blasso\b", r"\bridge\b", r"\belastic[- ]net\b",
        r"\blogistic\b", r"\bordinal\b", r"\bmultinomial\b",
        r"\bpoisson\b", r"\bnegative[- ]binomial\b",
    ],
    "hypothesis-testing": [
        r"\bt[- ]test\b", r"\banova\b", r"\bchi[- ]square\b",
        r"\bhypothesis\b", r"\bp[- ]value\b", r"\bcontrast\b",
        r"\bgoodness[- ]of[- ]fit\b",
    ],
    "non-parametric": [
        r"\bnon[- ]parametric\b", r"\brank[- ]?test\b",
        r"\bspearman\b", r"\bwilcoxon\b", r"\bkruskal\b",
        r"\bbootstrap\b", r"\bpermutation\b",
    ],
    "design-and-power": [
        r"\bpower\b", r"\bsample[- ]size\b", r"\bdesign\b",
        r"\bfactorial\b", r"\brcbd\b", r"\bblocking\b",
        r"\bcrossover\b", r"\brandomi[sz]ation\b",
    ],
    "causal-inference": [
        r"\bcausal\b", r"\bdag\b", r"\bpropensity\b",
        r"\biptw\b", r"\bg[- ]methods?\b", r"\bdid\b",
        r"\bdifference[- ]in[- ]differences?\b", r"\binstrumental\b",
        r"\bconfound", r"\brdd\b",
    ],
    "longitudinal-and-mixed": [
        r"\bmixed[- ]model\b", r"\bgee\b", r"\blongitudinal\b",
        r"\brepeated[- ]measures\b", r"\bgrowth curve\b",
        r"\blme4\b", r"\brandom[- ]effects?\b",
    ],
    "time-to-event": [
        r"\bsurvival\b", r"\bhazard\b", r"\bkaplan\b", r"\bcox\b",
        r"\bcensor", r"\btime[- ]to[- ]event\b", r"\blog[- ]rank\b",
        r"\bcompeting[- ]risks?\b", r"\bmultistate\b",
    ],
    "diagnostics-and-prediction": [
        r"\broc\b", r"\bauc\b", r"\bbrier\b", r"\bcalibrat",
        r"\bdiscriminat", r"\bdiagnostic\b", r"\bsensitivity\b",
        r"\bspecificity\b", r"\blikelihood ratio\b",
        r"\bdecision[- ]curve\b", r"\bnri\b", r"\bidi\b",
        r"\btripod\b", r"\bvalidation\b", r"\bbiomarker\b",
    ],
    "agreement-reliability": [
        r"\bagreement\b", r"\breliability\b", r"\bkappa\b",
        r"\bicc\b", r"\bbland[- ]altman\b", r"\bconcordance\b",
    ],
    "multivariate-and-dimreduction": [
        r"\bpca\b", r"\bfa\b", r"\bcca\b", r"\blda\b",
        r"\bumap\b", r"\bt[- ]sne\b", r"\bcluster",
        r"\bdimensionality\b", r"\bunsupervised\b",
    ],
    "machine-learning-methods": [
        r"\brandom forest\b", r"\bxgboost\b", r"\bboost",
        r"\bdeep learning\b", r"\bneural\b", r"\btorch\b",
        r"\bsvm\b", r"\bensemble\b", r"\btidymodels\b",
        r"\bcross[- ]validation\b", r"\bregularisation\b",
        r"\binterpretability\b", r"\bshap\b",
    ],
    "bayesian-methods": [
        r"\bbayes", r"\bposterior\b", r"\bprior\b", r"\bmcmc\b",
        r"\bstan\b", r"\bbrms\b", r"\bhierarchical\b", r"\bloo\b",
    ],
    "missing-data": [
        r"\bmissing\b", r"\bmcar\b", r"\bmar\b", r"\bmnar\b",
        r"\bimputation\b", r"\bmice\b",
    ],
    "evidence-synthesis": [
        r"\bmeta[- ]analysis\b", r"\bsystematic review\b",
        r"\bprisma\b", r"\bforest plot\b", r"\bnetwork meta\b",
        r"\bheterogeneity\b",
    ],
    "omics-and-genomics": [
        r"\brna[- ]seq\b", r"\bscrna\b", r"\bsingle[- ]cell\b",
        r"\bdeseq", r"\bedger\b", r"\bseurat\b", r"\bgsea\b",
        r"\bomics\b", r"\benrichment\b", r"\bbiomarker\b",
        r"\bdifferential expression\b",
    ],
    "high-dimensional": [
        r"\bhigh[- ]dimensional\b", r"\bregularis", r"\bfdr\b",
        r"\bmultiple[- ]testing\b", r"\bknockoff", r"\blasso\b",
        r"\bdimensionality\b",
    ],
    "reproducibility-and-reporting": [
        r"\bquarto\b", r"\brenv\b", r"\bworkflow\b", r"\breporting\b",
        r"\breproducib", r"\bpre[- ]registration\b", r"\bsap\b",
        r"\bstrobe\b", r"\bconsort\b", r"\btripod\b", r"\bprisma\b",
    ],
    "probability-and-distributions": [
        r"\bdistribution\b", r"\bprobability\b", r"\bbayes' theorem\b",
        r"\bpoisson\b", r"\bbinomial\b", r"\bbernoulli\b",
        r"\bnormal\b", r"\bqq[- ]plot\b",
    ],
    "asymptotic-and-foundations": [
        r"\bclt\b", r"\bcentral limit\b", r"\blikelihood\b",
        r"\bestimation\b", r"\bstandard error", r"\bsampling\b",
        r"\bfoundations?\b",
    ],
}

_COMPILED_PATTERNS = {
    tag: [re.compile(p, re.IGNORECASE) for p in patterns]
    for tag, patterns in MID_LEVEL_TAGS.items()
}


def _derive_mid_tags(title: str, base_tags: list[str]) -> list[str]:
    haystack = " ".join([title or "", " ".join(base_tags or [])])
    return [tag for tag, regs in _COMPILED_PATTERNS.items()
            if any(r.search(haystack) for r in regs)]


# --------------------------------------------------------------------------- #
# Minimal YAML parser — only the shapes we read.
# --------------------------------------------------------------------------- #

def parse_topics(text: str) -> list[dict]:
    return _parse_list_under(text, "topics")


def parse_labs(text: str) -> list[dict]:
    return _parse_list_under(text, "labs")


def _parse_list_under(text: str, key: str) -> list[dict]:
    rows: list[dict] = []
    cur: dict | None = None
    in_list = False
    for raw in text.splitlines():
        line = raw.split("#", 1)[0].rstrip() if "#" in raw else raw.rstrip()
        if not line.strip():
            continue
        if line.strip() == f"{key}:":
            in_list = True
            continue
        if not in_list:
            continue
        if line.startswith("  - "):
            if cur is not None:
                rows.append(cur)
            cur = {}
            rest = line[4:].strip()
            if ":" in rest:
                k, _, v = rest.partition(":")
                cur[k.strip()] = _coerce(v.strip())
            continue
        if line.startswith("    ") and cur is not None and ":" in line:
            k, _, v = line.strip().partition(":")
            cur[k.strip()] = _coerce(v.strip())
    if cur is not None:
        rows.append(cur)
    return rows


def _coerce(v: str):
    if v == "":
        return ""
    if v.startswith("[") and v.endswith("]"):
        try:
            return json.loads(v.replace("'", '"'))
        except json.JSONDecodeError:
            return v
    if v.startswith('"') and v.endswith('"'):
        return v[1:-1]
    if v.startswith("'") and v.endswith("'"):
        return v[1:-1]
    if v.lstrip("-").isdigit():
        try:
            return int(v)
        except ValueError:
            return v
    return v


# --------------------------------------------------------------------------- #
# Pipeline
# --------------------------------------------------------------------------- #

class BuildError(Exception):
    pass


def main() -> int:
    try:
        if not LABS_YAML.exists():
            raise BuildError(f"missing {LABS_YAML.relative_to(ROOT)}")
        if not COURSES_YAML.exists():
            raise BuildError(f"missing {COURSES_YAML.relative_to(ROOT)}")

        topics = parse_topics(COURSES_YAML.read_text(encoding="utf-8"))
        labs = parse_labs(LABS_YAML.read_text(encoding="utf-8"))
        if not topics:
            raise BuildError("courses.yml parsed empty")
        if not labs:
            raise BuildError("labs.yml parsed empty")

        topic_by_slug = {t["slug"]: t for t in topics}
        for t in topics:
            for k in ("slug", "display", "color", "order"):
                if k not in t:
                    raise BuildError(f"topic missing key '{k}': {t!r}")

        nodes = []
        seen_courses: set[str] = set()
        for L in labs:
            cid = L.get("course")
            if cid not in topic_by_slug:
                raise BuildError(f"lab {L.get('id')!r} references unknown course {cid!r}")
            if not L.get("title"):
                raise BuildError(f"lab {L.get('id')!r} missing title")
            seen_courses.add(cid)
            tags = L.get("tags") or []
            if isinstance(tags, str):
                tags = [tags]
            slug = L["id"]
            stem = slug.split("/", 1)[1]
            url = f"{COURSE_DIR[cid]}/labs/{stem}.html"

            # Enrich the hand-curated tags with cross-course method-family
            # tags (regex over title+tags) and a `course:<slug>` tag so
            # same-course labs cluster in the layout. Same approach as
            # the tutorials site; keeps the graph dense across the
            # otherwise-disjoint course boundaries.
            mid = _derive_mid_tags(L["title"], tags)
            course_tag = f"course:{cid}"
            seen_t: set[str] = set()
            enriched: list[str] = []
            for t in [*tags, course_tag, *mid]:
                if t and t not in seen_t:
                    seen_t.add(t)
                    enriched.append(t)

            nodes.append({
                "id": slug,
                "title": L["title"],
                "url": url,
                "topic": cid,
                "tags": enriched,
                "labels": [],          # courses have no separate labels axis
                "date": "",            # not tracked in courses
                "year": 0,
                "summary": "",
                "week": L.get("week"),
                "session": L.get("session"),
            })

        empty = set(topic_by_slug) - seen_courses
        if empty:
            raise BuildError(f"courses with zero labs: {sorted(empty)}")

        # Edges: ≥2 shared tags. Inverted index for speed.
        idx_for_tag: dict[str, list[int]] = defaultdict(list)
        for i, n in enumerate(nodes):
            for tag in n["tags"]:
                idx_for_tag[tag].append(i)
        pair: dict[tuple[int, int], int] = defaultdict(int)
        for ids in idx_for_tag.values():
            if len(ids) < 2:
                continue
            for i, j in combinations(ids, 2):
                pair[(i, j)] += 1
        edges = [
            {"source": nodes[i]["id"], "target": nodes[j]["id"], "weight": w}
            for (i, j), w in pair.items() if w >= SHARED_TAG_THRESHOLD
        ]
        if not edges:
            raise BuildError("computed graph has zero edges")

        # Facets.
        topic_count = defaultdict(int)
        tag_count = defaultdict(int)
        for n in nodes:
            topic_count[n["topic"]] += 1
            for t in n["tags"]:
                tag_count[t] += 1

        facets = {
            "topics": [
                {
                    "id": t["slug"],
                    "label": t["display"],
                    "color": t["color"],
                    "blurb": t.get("blurb", ""),
                    "order": t["order"],
                    "href": t.get("href", ""),
                    "count": topic_count[t["slug"]],
                }
                for t in sorted(topics, key=lambda x: x["order"])
            ],
            "tags": [
                {"id": k, "label": k, "count": v}
                for k, v in sorted(tag_count.items(), key=lambda kv: (-kv[1], kv[0]))
            ],
            "labels": [],
        }

        # Co-occurrence CSV.
        co_pair: dict[tuple[str, str], int] = defaultdict(int)
        for n in nodes:
            for a, b in combinations(sorted(set(n["tags"])), 2):
                co_pair[(a, b)] += 1
        co_rows = sorted(co_pair.items(), key=lambda kv: -kv[1])

        ARTIFACTS.mkdir(parents=True, exist_ok=True)
        graph_path = ARTIFACTS / "graph.json"
        graph_path.write_text(
            json.dumps({"nodes": nodes, "edges": edges, **facets}, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        with (ARTIFACTS / "labs.csv").open("w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow(["id", "title", "url", "course", "week", "session", "tags"])
            for n in nodes:
                w.writerow([n["id"], n["title"], n["url"], n["topic"],
                            n["week"], n["session"], "|".join(n["tags"])])
        with (ARTIFACTS / "cooccurrence.csv").open("w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow(["tag_a", "tag_b", "count"])
            for (a, b), c in co_rows:
                w.writerow([a, b, c])

        print(
            f"build_graph: {len(nodes)} labs, {len(edges)} edges, "
            f"{len(facets['topics'])} courses, {len(facets['tags'])} tags "
            f"-> {graph_path.relative_to(ROOT)}"
        )
        return 0
    except BuildError as e:
        print(f"build_graph: ERROR -- {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
