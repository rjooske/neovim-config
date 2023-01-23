local M = {}

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
    mode = "n",
    lhs = "<leader>o",
    rhs = require("telescope.builtin").find_files,
    desc = "Find files (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fo",
    rhs = function()
      require("telescope.builtin").oldfiles({ only_cwd = true })
    end,
    desc = "Recently opened files in current directory (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>O",
    rhs = function()
      require("telescope.builtin").oldfiles({ only_cwd = false })
    end,
    desc = "Recently opened files (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fg",
    rhs = require("telescope.builtin").live_grep,
    desc = "Live-grep in current directory (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fq",
    rhs = require("telescope.builtin").quickfix,
    desc = "Open quickfix (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fb",
    rhs = require("telescope.builtin").buffers,
    desc = "Find buffers (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fh",
    rhs = require("telescope.builtin").help_tags,
    desc = "Find help (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fs",
    rhs = require("telescope.builtin").current_buffer_fuzzy_find,
    desc = "Find lines in current buffer (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fd",
    rhs = require("telescope.builtin").diagnostics,
    desc = "Find diagnostics (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fc",
    rhs = require("telescope.builtin").command_history,
    desc = "Find command history (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fu",
    rhs = require("telescope.builtin").resume,
    desc = "Resume Telescope session (Telescope)",
  },

  {
    mode = { "n", "i", "s" },
    lhs = "<s-tab>",
    rhs = require("snippy.mapping").previous("<s-tab>"),
    desc = "Previous snippet tabstop (Snippy)",
  },
  {
    mode = { "n", "i", "s" },
    lhs = "<tab>",
    rhs = require("snippy.mapping").next("<tab>"),
    desc = "Next snippet tabstop (Snippy)",
  },
  {
    mode = "x",
    lhs = "<tab>",
    rhs = require("snippy.mapping").cut_text,
  },
  {
    mode = "n",
    lhs = "g<tab>",
    rhs = require("snippy.mapping").cut_text,
  },
}

local diagnostic_float_opts = {
  source = "always",
  scope = "line",
  border = "rounded",
}

---@type Keymap[]
M.lsp_keymaps = {
  {
    mode = "n",
    lhs = "gl",
    rhs = function()
      vim.diagnostic.open_float(diagnostic_float_opts)
    end,
    desc = "Open diagnostics on the current line",
  },
  {
    mode = "n",
    lhs = "]d",
    rhs = function()
      vim.diagnostic.goto_next({ float = diagnostic_float_opts })
    end,
    desc = "Go to the next diagnostic",
  },
  {
    mode = "n",
    lhs = "[d",
    rhs = function()
      vim.diagnostic.goto_prev({ float = diagnostic_float_opts })
    end,
    desc = "Go to the previous diagnostic",
  },
  {
    mode = "n",
    lhs = "K",
    rhs = vim.lsp.buf.hover,
  },
  {
    mode = "n",
    lhs = "gD",
    rhs = vim.lsp.buf.declaration,
  },
  {
    mode = "n",
    lhs = "gd",
    rhs = require("telescope.builtin").lsp_definitions,
  },
  {
    mode = "n",
    lhs = "gi",
    rhs = require("telescope.builtin").lsp_implementations,
  },
  {
    mode = "n",
    lhs = "gr",
    rhs = require("telescope.builtin").lsp_references,
  },
  {
    mode = "n",
    lhs = "<space>D",
    rhs = require("telescope.builtin").lsp_type_definitions,
  },
  {
    mode = "n",
    lhs = "<space>rn",
    rhs = vim.lsp.buf.rename,
    desc = "Rename",
  },
  {
    mode = "n",
    lhs = "<space>ca",
    rhs = vim.lsp.buf.code_action,
    desc = "Code action",
  },
  {
    mode = "n",
    lhs = "<leader>fy",
    rhs = require("telescope.builtin").lsp_dynamic_workspace_symbols,
    desc = "Query workspace symbols (Telescope)",
  },
}

return M
