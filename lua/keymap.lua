local M = {}

local telescope_builtin = require("telescope.builtin")
local snippy_mapping = require("snippy.mapping")
local gitsigns = require("gitsigns")

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
    lhs = "<leader>fe",
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
    lhs = "<leader>fd",
    rhs = telescope_builtin.diagnostics,
    desc = "Find diagnostics (Telescope)",
  },
  {
    mode = "n",
    lhs = "<leader>fc",
    rhs = telescope_builtin.command_history,
    desc = "Find command history (Telescope)",
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
}

local diagnostic_float_opts = {
  source = "always",
  scope = "line",
  border = "rounded",
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
    mode = "n",
    lhs = "gl",
    rhs = function()
      vim.diagnostic.open_float(diagnostic_float_opts)
    end,
    desc = "Diagnostics on current line",
  },
  {
    mode = "n",
    lhs = "]d",
    rhs = function()
      vim.diagnostic.goto_next({ float = diagnostic_float_opts })
    end,
    desc = "Next diagnostic",
  },
  {
    mode = "n",
    lhs = "[d",
    rhs = function()
      vim.diagnostic.goto_prev({ float = diagnostic_float_opts })
    end,
    desc = "Previous diagnostic",
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
    lhs = "<space>D",
    rhs = as_jump(telescope_builtin.lsp_type_definitions),
    desc = "Type definitions (Telescope)",
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
    rhs = telescope_builtin.lsp_dynamic_workspace_symbols,
    desc = "Query workspace symbols (Telescope)",
  },
}

return M
