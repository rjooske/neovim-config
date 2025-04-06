local M = {}

local cmp = require("cmp")
local cmp_compare = require("cmp.config.compare")
local lspkind = require("lspkind")
local snippy = require("snippy")

local select_prev =
  cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })
local select_next =
  cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })

-- Grabs words from all the open buffers
local source_all_buffers = {
  name = "buffer",
  option = { get_bufnrs = vim.api.nvim_list_bufs },
}

---@param s string
---@param max_len integer
---@return string
local function ellipsize(s, max_len)
  local ellipsis = "…"
  if #s > max_len then
    return s:sub(1, max_len - #ellipsis) .. ellipsis
  else
    return s
  end
end

---@return boolean
local function cmp_entry_has_imports(entry)
  local i = entry:get_completion_item()
  return i.data ~= nil and i.data.imports ~= nil
end

---@return boolean?
local function non_importing_entries_come_earlier(entry_a, entry_b)
  local a_has_imports = cmp_entry_has_imports(entry_a)
  local b_has_imports = cmp_entry_has_imports(entry_b)
  if a_has_imports and not b_has_imports then
    return false
  elseif not a_has_imports and b_has_imports then
    return true
  end
  return nil
end

M.setup = function()
  snippy.setup({
    virtual_markers = {
      enabled = true,
      default = "!",
      empty = "?",
      hl_group = "Error",
    },
  })

  local cmp_abort = cmp.mapping.abort()
  local cmp_complete = cmp.mapping.complete()
  local function cmp_toggle()
    if cmp.visible() then
      cmp_abort()
    else
      cmp_complete()
    end
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        snippy.expand_snippet(args.body)
      end,
    },
    formatting = {
      format = function(entry, item)
        local t = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 40,
          ellipsis_char = "…",
        })(entry, item)
        if t.menu ~= nil then
          t.menu = ellipsize(t.menu, 40)
        end
        return t
      end,
    },
    mapping = {
      ["<C-Space>"] = { i = cmp_toggle, c = cmp_toggle },
      ["<c-p>"] = { i = select_prev },
      ["<c-n>"] = { i = select_next },
      ["<up>"] = { i = select_prev },
      ["<down>"] = { i = select_next },
      ["<cr>"] = { i = cmp.mapping.confirm({ select = false }) },
      ["<c-u>"] = { i = cmp.mapping.scroll_docs(-4) },
      ["<c-d>"] = { i = cmp.mapping.scroll_docs(4) },
    },
    sources = cmp.config.sources({
      { name = "snippy" },
      { name = "nvim_lsp" },
    }, { source_all_buffers }),
    -- Select the first entry automatically
    completion = { completeopt = "menu,menuone,noinsert" },
    -- Ignore preselect requests from language servers
    preselect = cmp.PreselectMode.None,
  })

  cmp.setup.filetype("rust", {
    -- Default sorting from nvim-cmp/lua/cmp/config/default.lua
    sorting = {
      priority_weight = 2,
      comparators = {
        cmp_compare.offset,
        cmp_compare.exact,
        non_importing_entries_come_earlier,
        -- cmp_compare.scopes,
        cmp_compare.score,
        cmp_compare.recently_used,
        cmp_compare.locality,
        cmp_compare.kind,
        -- cmp_compare.sort_text,
        cmp_compare.length,
        cmp_compare.order,
      },
    },
  })

  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = "buffer" } },
    -- NOT select the first entry automatically
    completion = { completeopt = "menu,preview,noselect" },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
    -- NOT select the first entry automatically
    completion = { completeopt = "menu,preview,noselect" },
  })
end

return M
