local M = {}

local cmp = require("cmp")
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

M.setup = function()
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
