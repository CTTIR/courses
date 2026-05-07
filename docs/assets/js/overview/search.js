// Pagefind search bridge. Hooks the search input on overview.qmd to
// `controller.setQuery()` with a 150ms debounce, then runs the query
// through Pagefind to get a Set<node-id> of matches plus an order hint.
//
// Mapping Pagefind hit -> node id: hits expose `url` like
// "tutorials/<topic>/<slug>.html"; the node id in graph.json is
// "<topic>/<slug>". We strip the prefix and the .html.

const DEBOUNCE_MS = 150;

export function createSearch({ root, graph, controller, onResults }) {
  const input = document.getElementById("overview-search");
  if (!input) return { update() {} };

  // Index: url -> node.id
  const urlToId = new Map();
  for (const n of graph.nodes) {
    urlToId.set(normaliseUrl(n.url), n.id);
  }

  let pagefind = null;
  let pagefindFailed = false;
  async function ensurePagefind() {
    if (pagefind || pagefindFailed) return pagefind;
    try {
      // Pagefind ships its runtime as an ES module at /pagefind/pagefind.js.
      const url = root + "pagefind/pagefind.js";
      pagefind = await import(/* @vite-ignore */ url);
      if (pagefind.options) {
        await pagefind.options({ excerptLength: 30 });
      }
    } catch (e) {
      console.warn("Pagefind unavailable:", e);
      pagefindFailed = true;
      pagefind = null;
    }
    return pagefind;
  }

  let timer = null;
  input.addEventListener("input", () => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      controller.setQuery(input.value.trim());
    }, DEBOUNCE_MS);
  });

  // The controller drives us via update(); we run the query and
  // notify listeners with the resolved hits.
  async function update(state /* , currentHits unused */) {
    if (input.value.trim() !== state.query) input.value = state.query;
    if (!state.query) {
      onResults({ hits: null, snippets: new Map(), order: [] });
      return;
    }
    const pf = await ensurePagefind();
    if (!pf) {
      onResults({ hits: new Set(), snippets: new Map(), order: [] });
      return;
    }
    try {
      const search = await pf.search(state.query);
      const dataPromises = search.results.slice(0, 200).map(r => r.data());
      const data = await Promise.all(dataPromises);
      const hits = new Set();
      const snippets = new Map();
      const order = [];
      for (const d of data) {
        const id = urlToId.get(normaliseUrl(d.url));
        if (!id) continue;
        if (!hits.has(id)) {
          hits.add(id);
          order.push(id);
          if (d.excerpt) snippets.set(id, d.excerpt);
        }
      }
      onResults({ hits, snippets, order });
    } catch (e) {
      console.warn("Pagefind search failed:", e);
      onResults({ hits: new Set(), snippets: new Map(), order: [] });
    }
  }

  return { update };
}

// Pagefind URLs look like "/courseN_<long>/labs/lab_weekW_sessionS.html".
// Node IDs in graph.json look like "courseN/lab_weekW_sessionS". Map the
// long directory name back to the short course slug used in the IDs.
const DIR_TO_COURSE = {
  course1_foundations:   "course1",
  course2_regression:    "course2",
  course3_design_causal: "course3",
  course4_ml_highdim:    "course4",
};

function normaliseUrl(u) {
  if (!u) return "";
  const m = u.match(/(course\d_[a-z_]+)\/labs\/([^/]+?)\.html/);
  if (!m) return "";
  const cslug = DIR_TO_COURSE[m[1]];
  if (!cslug) return "";
  return `${cslug}/${m[2]}`;
}
