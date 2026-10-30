// Pagefind search bridge. Hooks the search input on overview.qmd to
// `controller.setQuery()` with a 150ms debounce, then runs the query
// through Pagefind to get a Set<node-id> of matches plus an order hint.
//
// Mapping Pagefind hit -> node id: hits expose `url` like
// "tutorials/<topic>/<slug>.html"; the node id in graph.json is
// "<topic>/<slug>". We strip the prefix and the .html.

const DEBOUNCE_MS = 150;

export function createSearch({ root, graph, controller, onResults,
  loadModule = url => import(/* @vite-ignore */ url) }) {
  const input = document.getElementById("overview-search");
  if (!input) return { update() {} };

  // Index: url -> node.id
  const urlToId = new Map();
  for (const n of graph.nodes) {
    urlToId.set(normaliseUrl(n.url), n.id);
  }

  let pagefind = null;
  let loading = null;
  async function ensurePagefind() {
    if (pagefind) return pagefind;
    if (loading) return loading;
    loading = loadPagefind();
    return loading;
  }
  async function loadPagefind() {
    try {
      // Pagefind ships its runtime as an ES module at /pagefind/pagefind.js.
      // Resolve against the document, not this module's assets/js/ directory.
      const url = new URL(root + "pagefind/pagefind.js", document.baseURI).href;
      const module = await loadModule(url);
      if (module.options) {
        await module.options({ excerptLength: 30 });
      }
      pagefind = module;
    } catch (e) {
      console.warn("Pagefind unavailable:", e);
      pagefind = null;
    } finally {
      loading = null;
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
  let generation = 0;
  async function update(state /* , currentHits unused */) {
    const request = ++generation;
    const query = state.query;
    if (input.value.trim() !== state.query) input.value = state.query;
    if (!query) {
      onResults({ hits: null, snippets: new Map(), order: [] });
      return;
    }
    const pf = await ensurePagefind();
    if (request !== generation) return;
    if (!pf) {
      onResults({ hits: new Set(), snippets: new Map(), order: [],
        error: "Search could not load. Clear the search to browse all labs, or try again." });
      return;
    }
    try {
      const search = await pf.search(query);
      const dataPromises = search.results.slice(0, 200).map(r => r.data());
      const data = await Promise.all(dataPromises);
      if (request !== generation) return;
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
      if (request !== generation) return;
      console.warn("Pagefind search failed:", e);
      onResults({ hits: new Set(), snippets: new Map(), order: [],
        error: "Search failed. Clear the search to browse all labs, or try again." });
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
