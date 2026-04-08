local M = {}

local format = require("format")
local gitsigns = require("gitsigns")
local snippy_mapping = require("snippy.mapping")
local telescope_builtin = require("telescope.builtin")

---@param key string
---@return string
local function jump_with_mark(key)
  if vim.v.count1 > 1 then
    return "m'" .. vim.v.count1 .. key
  else
    return key
  end
end

M.leader = " "

---@class NonExprKeymap
---@field mode string | string[]
---@field lhs string
---@field rhs string | fun()
---@field desc string

---@class ExprKeymap
---@field mode string | string[]
---@field lhs string
---@field rhs fun(): string
---@field desc string
---@field expr true

---@alias Keymap NonExprKeymap | ExprKeymap

---@type Keymap[]
M.keymaps = {
  {
    mode = { "n", "x" },
    lhs = "j",
    rhs = function()
      return jump_with_mark("j")
    end,
    desc = "Leave a mark when moving down multiple lines at once",
    expr = true,
  },
  {
    mode = { "n", "x" },
    lhs = "k",
    rhs = function()
      return jump_with_mark("k")
    end,
    desc = "Leave a mark when moving up multiple lines at once",
    expr = true,
  },

  {
    mode = "n",
    lhs = "<leader>w",
    rhs = "<cmd>w<cr>",
    desc = "Save",
  },
  {
    mode = "n",
    lhs = "<leader>W",
    rhs = "<cmd>noautocmd w<cr>",
    desc = "Save without formatting",
  },
  {
    mode = "n",
    lhs = "<leader>q",
    rhs = "<cmd>close<cr>",
    desc = "Close window except last one",
  },
  {
    mode = "n",
    lhs = "<leader><leader>q",
    rhs = "<cmd>qa<cr>",
    desc = "Close all windows",
  },
  {
    mode = "n",
    lhs = "<leader><leader><leader>q",
    rhs = "<cmd>cq<cr>",
    desc = "Exit with error code",
  },
  {
    mode = "n",
    lhs = "<esc>",
    rhs = "<cmd>noh<cr>",
    desc = "Clear search highlights",
  },
  {
    mode = "x",
    lhs = "/",
    rhs = [[<esc>/\%V]],
    desc = "Search within visual selection",
  },

  {
    mode = { "n", "x" },
    lhs = "<leader>y",
    rhs = '"*y',
    desc = "`y` with `*` register",
  },
  {
    mode = { "n", "x" },
    lhs = "<leader>Y",
    rhs = '"*Y',
    desc = "`Y` with `*` register",
  },
  {
    mode = { "n", "x" },
    lhs = "<leader>p",
    rhs = '"*p',
    desc = "`p` with `*` register",
  },
  {
    mode = { "n", "x" },
    lhs = "<leader>P",
    rhs = '"*P',
    desc = "`P` with `*` register",
  },

  {
    mode = "n",
    lhs = "<Leader>t",
    rhs = "<Cmd>vsplit | terminal<CR>",
    desc = "Open terminal in a vertical split",
  },
  {
    mode = "n",
    lhs = "<Leader>T",
    rhs = "<Cmd>split | terminal<CR>",
    desc = "Open terminal in a horizontal split",
  },

  {
    mode = { "n", "t" },
    lhs = "<M-h>",
    rhs = "<Cmd>:wincmd h<CR>",
    desc = "Move cursor to the window on the left",
  },
  {
    mode = { "n", "t" },
    lhs = "<M-j>",
    rhs = "<Cmd>:wincmd j<CR>",
    desc = "Move cursor to the window below",
  },
  {
    mode = { "n", "t" },
    lhs = "<M-k>",
    rhs = "<Cmd>:wincmd k<CR>",
    desc = "Move cursor to the window above",
  },
  {
    mode = { "n", "t" },
    lhs = "<M-l>",
    rhs = "<Cmd>:wincmd l<CR>",
    desc = "Move cursor to the window on the right",
  },

  {
    mode = "n",
    lhs = "[t",
    rhs = "<cmd>tabprevious<cr>",
    desc = "Previous tab page",
  },
  {
    mode = "n",
    lhs = "]t",
    rhs = "<cmd>tabnext<cr>",
    desc = "Next tab page",
  },
  {
    mode = "n",
    lhs = "[T",
    rhs = "<cmd>tabmove -1<cr>",
    desc = "Move the tab page to the left",
  },
  {
    mode = "n",
    lhs = "]T",
    rhs = "<cmd>tabmove +1<cr>",
    desc = "Move the tab page to the right",
  },

  {
    mode = "n",
    lhs = "[q",
    rhs = "<cmd>cprevious<cr>zz",
    desc = "Previous quickfix",
  },
  {
    mode = "n",
    lhs = "]q",
    rhs = "<cmd>cnext<cr>zz",
    desc = "Next quickfix",
  },
  {
    mode = "n",
    lhs = "[Q",
    rhs = "<cmd>cfirst<cr>zz",
    desc = "First quickfix",
  },
  {
    mode = "n",
    lhs = "]Q",
    rhs = "<cmd>clast<cr>zz",
    desc = "Last quickfix",
  },

  {
    mode = "n",
    lhs = "<leader>o",
    rhs = telescope_builtin.find_files,
    desc = "Find files (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fo",
    rhs = function()
      telescope_builtin.oldfiles({ only_cwd = true })
    end,
    desc = "Recently opened files in current directory (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>O",
    rhs = function()
      telescope_builtin.oldfiles({ only_cwd = false })
    end,
    desc = "Recently opened files (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>b",
    rhs = telescope_builtin.buffers,
    desc = "Find buffers (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fg",
    rhs = telescope_builtin.live_grep,
    desc = "Live-grep in current directory (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fq",
    rhs = telescope_builtin.quickfix,
    desc = "Open quickfix (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fh",
    rhs = telescope_builtin.help_tags,
    desc = "Find help (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fs",
    rhs = telescope_builtin.current_buffer_fuzzy_find,
    desc = "Find lines in current buffer (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fc",
    rhs = telescope_builtin.command_history,
    desc = "Find command history (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fk",
    rhs = function()
      telescope_builtin.keymaps({ show_plug = false })
    end,
    desc = "Find keymaps (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>gs",
    rhs = telescope_builtin.git_status,
    desc = "Git status (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fd",
    rhs = telescope_builtin.diagnostics,
    desc = "Find diagnostics (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fD",
    rhs = function()
      telescope_builtin.diagnostics({ bufnr = 0 })
    end,
    desc = "Find diagnostics in current buffer (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fe",
    rhs = function()
      telescope_builtin.diagnostics({
        severity_limit = vim.diagnostic.severity.ERROR,
      })
    end,
    desc = "Find error diagnostics (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fE",
    rhs = function()
      telescope_builtin.diagnostics({
        bufnr = 0,
        severity_limit = vim.diagnostic.severity.ERROR,
      })
    end,
    desc = "Find error diagnostics in current buffer (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fy",
    rhs = telescope_builtin.lsp_dynamic_workspace_symbols,
    desc = "Query workspace symbols (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fu",
    rhs = telescope_builtin.resume,
    desc = "Resume Telescope session (Telescope)",
  },

  {
    mode = { "n", "i", "s" },
    lhs = "<s-tab>",
    rhs = snippy_mapping.previous("<s-tab>"),
    desc = "Previous snippet tabstop (Snippy)",
  },
  {
    mode = { "n", "i", "s" },
    lhs = "<tab>",
    rhs = snippy_mapping.next("<tab>"),
    desc = "Next snippet tabstop (Snippy)",
  },
  {
    mode = "x",
    lhs = "<tab>",
    rhs = snippy_mapping.cut_text,
    desc = "Cut text (Snippy)",
  },
  {
    mode = "n",
    lhs = "g<tab>",
    rhs = snippy_mapping.cut_text,
    desc = "Cut text (Snippy)",
  },

  {
    mode = "n",
    lhs = "[h",
    rhs = gitsigns.prev_hunk,
    desc = "Previous hunk (Gitsigns)",
  },
  {
    mode = "n",
    lhs = "]h",
    rhs = gitsigns.next_hunk,
    desc = "Next hunk (Gitsigns)",
  },

  {
    mode = "n",
    lhs = "<Leader>xl",
    rhs = ":TSJToggle<CR>",
    desc = "Split or join nodes (Treesj)",
  },
  {
    mode = "n",
    lhs = "<Leader>xk",
    rhs = ":TSJSplit<CR>",
    desc = "Split nodes (Treesj)",
  },
  {
    mode = "n",
    lhs = "<Leader>xj",
    rhs = ":TSJJoin<CR>",
    desc = "Join nodes (Treesj)",
  },
}

local function as_jump(f)
  return function()
    vim.cmd("normal m'")
    f()
  end
end

---@type Keymap[]
M.lsp_keymaps = {
  {
    mode = "i",
    lhs = "<c-k>",
    rhs = vim.lsp.buf.signature_help,
    desc = "Signature help",
  },

  {
    mode = "n",
    lhs = "gl",
    rhs = vim.diagnostic.open_float,
    desc = "Diagnostics on the current line",
  },
  {
    mode = "n",
    lhs = "[d",
    rhs = function()
      vim.diagnostic.jump({
        count = -1,
        float = true,
      })
    end,
    desc = "Previous diagnostic",
  },
  {
    mode = "n",
    lhs = "]d",
    rhs = function()
      vim.diagnostic.jump({
        count = 1,
        float = true,
      })
    end,
    desc = "Next diagnostic",
  },
  {
    mode = "n",
    lhs = "[e",
    rhs = function()
      vim.diagnostic.jump({
        count = -1,
        float = true,
        severity = vim.diagnostic.severity.ERROR,
      })
    end,
    desc = "Previous error diagnostic",
  },
  {
    mode = "n",
    lhs = "]e",
    rhs = function()
      vim.diagnostic.jump({
        count = 1,
        float = true,
        severity = vim.diagnostic.severity.ERROR,
      })
    end,
    desc = "Next error diagnostic",
  },

  {
    mode = "n",
    lhs = "K",
    rhs = vim.lsp.buf.hover,
    desc = "Hover",
  },
  {
    mode = "n",
    lhs = "gD",
    rhs = vim.lsp.buf.declaration,
    desc = "Declaration",
  },
  {
    mode = "n",
    lhs = "gd",
    rhs = as_jump(telescope_builtin.lsp_definitions),
    desc = "Definitions (Telescope)",
  },
  {
    mode = "n",
    lhs = "gi",
    rhs = as_jump(telescope_builtin.lsp_implementations),
    desc = "Implementations (Telescope)",
  },
  {
    mode = "n",
    lhs = "gr",
    rhs = as_jump(telescope_builtin.lsp_references),
    desc = "References (Telescope)",
  },
  {
    mode = "n",
    lhs = "gy",
    rhs = as_jump(telescope_builtin.lsp_type_definitions),
    desc = "Type definitions (Telescope)",
  },
  {
    mode = "n",
    lhs = "<space>lr",
    rhs = vim.lsp.buf.rename,
    desc = "Rename",
  },
  {
    mode = "n",
    lhs = "<space>lf",
    rhs = function()
      format.format(vim.api.nvim_get_current_buf())
    end,
    desc = "Format",
  },
  {
    mode = "n",
    lhs = "<space>la",
    rhs = vim.lsp.buf.code_action,
    desc = "Code action",
  },
  {
    mode = "n",
    lhs = "<Leader>lw",
    rhs = vim.lsp.buf.document_highlight,
    desc = "Highlight word under cursor",
  },
  {
    mode = "n",
    lhs = "<Leader>le",
    rhs = vim.lsp.buf.clear_references,
    desc = "Clear word highlights",
  },
  {
    mode = "n",
    lhs = "<Leader>lR",
    rhs = function()
      vim.cmd("LspRestart")
    end,
    desc = "Restart all language servers",
  },
}

return M
