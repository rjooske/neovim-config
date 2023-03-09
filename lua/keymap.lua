local M = {}

local telescope_builtin = require("telescope.builtin")
local snippy_mapping = require("snippy.mapping")
local gitsigns = require("gitsigns")
local hop = require("hop")

M.leader = " "

---@class Keymap
---@field mode string | string[]
---@field lhs string
---@field rhs string | fun()
---@field desc string

---@type Keymap[]
M.keymaps = {
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
    mode = { "n", "v" },
    lhs = "<leader>y",
    rhs = '"*y',
    desc = "`y` with `*` register",
  },
  {
    mode = { "n", "v" },
    lhs = "<leader>Y",
    rhs = '"*Y',
    desc = "`Y` with `*` register",
  },
  {
    mode = { "n", "v" },
    lhs = "<leader>p",
    rhs = '"*p',
    desc = "`p` with `*` register",
  },
  {
    mode = { "n", "v" },
    lhs = "<leader>P",
    rhs = '"*P',
    desc = "`P` with `*` register",
  },
  {
    mode = "n",
    lhs = "<leader><leader>yr",
    rhs = function()
      vim.fn.setreg("*", vim.fn.expand("%:~:."), "c")
    end,
    desc = "Yank relative path of current file into `*` register",
  },

  {
    mode = "n",
    lhs = "<c-h>",
    rhs = "<cmd>wincmd h<cr>",
    desc = "Window to the left",
  },
  {
    mode = "n",
    lhs = "<c-j>",
    rhs = "<cmd>wincmd j<cr>",
    desc = "Window below",
  },
  {
    mode = "n",
    lhs = "<c-k>",
    rhs = "<cmd>wincmd k<cr>",
    desc = "Window above",
  },
  {
    mode = "n",
    lhs = "<c-l>",
    rhs = "<cmd>wincmd l<cr>",
    desc = "Window to the right",
  },
  {
    mode = "t",
    lhs = "<esc>",
    rhs = [[<c-\><c-n>]],
    desc = "Leave terminal mode",
  },
  {
    mode = "t",
    lhs = "<c-h>",
    rhs = [[<c-\><c-n><cmd>wincmd h<cr>]],
    desc = "Window to the left",
  },
  {
    mode = "t",
    lhs = "<c-j>",
    rhs = [[<c-\><c-n><cmd>wincmd j<cr>]],
    desc = "Window below",
  },
  {
    mode = "t",
    lhs = "<c-k>",
    rhs = [[<c-\><c-n><cmd>wincmd k<cr>]],
    desc = "Window above",
  },
  {
    mode = "t",
    lhs = "<c-l>",
    rhs = [[<c-\><c-n><cmd>wincmd l<cr>]],
    desc = "Window to the right",
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
    mode = { "n", "v" },
    lhs = "<leader>h",
    rhs = hop.hint_char2,
    desc = "Hop to bigram (Hop)",
  },
}

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
    rhs = vim.diagnostic.goto_prev,
    desc = "Previous diagnostic",
  },
  {
    mode = "n",
    lhs = "]d",
    rhs = vim.diagnostic.goto_next,
    desc = "Next diagnostic",
  },
  {
    mode = "n",
    lhs = "[e",
    rhs = function()
      vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end,
    desc = "Previous error diagnostic",
  },
  {
    mode = "n",
    lhs = "]e",
    rhs = function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
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
    rhs = telescope_builtin.lsp_definitions,
    desc = "Definitions (Telescope)",
  },
  {
    mode = "n",
    lhs = "gi",
    rhs = telescope_builtin.lsp_implementations,
    desc = "Implementations (Telescope)",
  },
  {
    mode = "n",
    lhs = "gr",
    rhs = telescope_builtin.lsp_references,
    desc = "References (Telescope)",
  },
  {
    mode = "n",
    lhs = "gy",
    rhs = telescope_builtin.lsp_type_definitions,
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
    lhs = "<space>la",
    rhs = vim.lsp.buf.code_action,
    desc = "Code action",
  },
}

return M
