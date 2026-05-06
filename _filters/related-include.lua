-- Append the matching Related-labs partial to every lab page at render time.
--
-- Pre-render emits _includes/related/<course>__<lab-stem>.html via
-- scripts/build_related.py. This filter looks up the partial that
-- matches the current lab and appends it to the rendered body.
--
-- Activates only on lab detail pages: courseN_*/labs/lab_*.qmd. No-op
-- elsewhere (course indexes, appendices, cheatsheets, about, …).

local function read_file(path)
  local fh = io.open(path, "rb")
  if not fh then return nil end
  local s = fh:read("*a")
  fh:close()
  return s
end

-- Long directory name -> course slug used in graph.json node IDs.
local DIR_TO_COURSE = {
  course1_foundations  = "course1",
  course2_regression   = "course2",
  course3_design_causal= "course3",
  course4_ml_highdim   = "course4",
}

local function detect_partial(input_file)
  if not input_file then return nil end
  local p = input_file:gsub("\\", "/")
  -- <course-dir>/labs/<stem>.qmd
  local cdir, stem = p:match("(course%d_[%w_]+)/labs/([^/]+)%.qmd$")
  if not cdir or not stem then return nil end
  local cslug = DIR_TO_COURSE[cdir]
  if not cslug then return nil end
  return cslug .. "__" .. stem
end

function Pandoc(doc)
  local src = quarto and quarto.doc and quarto.doc.input_file
  local key = detect_partial(src)
  if not key then return nil end

  local self_path = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/")
  local project_root = self_path:gsub("/_filters/[^/]+$", "")
  local partial = project_root .. "/_includes/related/" .. key .. ".html"

  local html = read_file(partial)
  if not html or html == "" then return nil end

  table.insert(doc.blocks, pandoc.RawBlock("html", html))
  return doc
end
