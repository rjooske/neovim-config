require("packer").startup(function(use)
  use("wbthomason/packer.nvim")

  use("neovim/nvim-lspconfig")
  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = "nvim-lua/plenary.nvim",
  })

  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-cmdline")
  use("hrsh7th/nvim-cmp")
  use("dcampos/nvim-snippy")
  use("dcampos/cmp-snippy")
  use("onsails/lspkind.nvim")

  use("simrat39/rust-tools.nvim")

  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  })
  use("SmiteshP/nvim-navic")
  use("stevearc/dressing.nvim")
  use("nvim-tree/nvim-web-devicons")
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons" },
  })

  use("ellisonleao/gruvbox.nvim")

  use({
    "nvim-telescope/telescope.nvim",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    },
  })

  use("tpope/vim-fugitive")
  use("lewis6991/gitsigns.nvim")

  use("famiu/bufdelete.nvim")

  use("windwp/nvim-autopairs")
  use("numToStr/Comment.nvim")
  use("phaazon/hop.nvim")
  use("kylechui/nvim-surround")

  use("dstein64/vim-startuptime")
end)

-- vim.cmd.colorscheme("rjooske")
vim.cmd.colorscheme("gruvbox")

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

vim.g.mapleader = require("keymap").leader
for _, v in ipairs(require("keymap").keymaps) do
  local opts = { silent = true, desc = v.desc }
  vim.keymap.set(v.mode, v.lhs, v.rhs, opts)
end

vim.keymap.set("n", "<leader>bd", function()
  local buftype = vim.api.nvim_buf_get_option(0, "buftype")
  local filetype = vim.api.nvim_buf_get_option(0, "filetype")
  local force = buftype == "terminal" or filetype == "netrw"
  require("bufdelete").bufdelete(0, force)
end)

for k, v in pairs(require("style").opt) do
  vim.opt[k] = v
end

for name, text in pairs(require("style").signs) do
  vim.fn.sign_define(name, { text = text, texthl = name })
end

local style_augroup = vim.api.nvim_create_augroup("RjooskeStyle", {})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = style_augroup,
  callback = function()
    local opts = require("indent").detect(0)
    if opts == nil then
      return
    end
    for k, v in pairs(opts) do
      vim.opt[k] = v
    end
    vim.opt.listchars = require("style").listchars(opts.tabstop)
  end,
})

local function format(bufnr)
  vim.lsp.buf.format({
    bufnr = bufnr,
    timeout_ms = 5000,
    filter = function(client)
      return client.name == "null-ls"
    end,
  })
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("FormatOnSave", {}),
  callback = function(event)
    if #vim.lsp.get_active_clients({ bufnr = event.buf }) > 0 then
      format(event.buf)
    end
  end,
})

local function on_attach(client, bufnr)
  -- Create a mapping local to this buffer
  local function map(mode, lhs, rhs, opts)
    opts.buffer = bufnr
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  if client.name == "null-ls" then
    map("n", "<leader>lf", function()
      format(bufnr)
    end, { desc = "Format" })
  end

  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end

  for _, v in ipairs(require("keymap").lsp_keymaps) do
    local opts = { silent = true, desc = v.desc }
    map(v.mode, v.lhs, v.rhs, opts)
  end
end

vim.diagnostic.config({
  severity_sort = true,
  float = {
    source = "always",
    scope = "line",
  },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.fn.expand("$VIMRUNTIME/lua"),
          -- require("packer").config.package_root,
        },
      },
    },
  },
})
lspconfig.clangd.setup({
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  on_attach = on_attach,
  capabilities = vim.tbl_extend(
    "force",
    capabilities,
    { offsetEncoding = "utf-8" }
  ),
})
lspconfig.pyright.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.tsserver.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.gopls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.jdtls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.arduino_language_server.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "arduino-language-server",
    "-cli-config",
    "/Users/rjooske/Library/Arduino15/arduino-cli.yaml",
    "-fqbn",
    "arduino:avr:nano:cpu=atmega328old",
    "-cli",
    "arduino-cli",
    "-clangd",
    "clangd",
  },
})
lspconfig.jsonls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.marksman.setup({ on_attach = on_attach, capabilities = capabilities })

local rust_tools = require("rust-tools")
rust_tools.setup({
  server = {
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = { command = "clippy" },
        inlayHints = { locationLinks = false },
      },
    },
    on_attach = on_attach,
    capabilities = capabilities,
  },
})

local eslint_condition = function(utils)
  return utils.root_has_file({
    -- https://eslint.org/docs/latest/user-guide/configuring/configuration-files-new
    "eslint.config.js",
    -- https://eslint.org/docs/user-guide/configuring/configuration-files#configuration-file-formats
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
  })
end

local null_ls = require("null-ls")
null_ls.setup({
  on_attach = on_attach,
  sources = {
    null_ls.builtins.diagnostics.cspell.with({
      -- Force the severity to be HINT
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity.HINT
      end,
    }),
    null_ls.builtins.code_actions.cspell,

    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.selene.with({
      condition = function(utils)
        return utils.root_has_file({ "selene.toml" })
      end,
    }),

    null_ls.builtins.formatting.clang_format.with({
      extra_filetypes = { "arduino" },
    }),

    null_ls.builtins.diagnostics.eslint_d.with({ condition = eslint_condition }),
    null_ls.builtins.code_actions.eslint_d.with({
      condition = eslint_condition,
    }),

    null_ls.builtins.formatting.prettierd,

    null_ls.builtins.diagnostics.flake8.with({
      extra_args = { "--ignore", "E203,E741" },
    }),
    null_ls.builtins.formatting.black.with({
      extra_args = { "--line-length", "79" },
    }),
    null_ls.builtins.formatting.isort,

    null_ls.builtins.formatting.rustfmt,

    null_ls.builtins.formatting.goimports,

    null_ls.builtins.formatting.taplo,
  },
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
    "comment",
    "cpp",
    "css",
    "gitcommit",
    "gitignore",
    "html",
    "java",
    "javascript",
    "jsonc",
    "latex",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "proto",
    "python",
    "rust",
    "scss",
    "sql",
    "toml",
    "typescript",
    "vim",
  },
  sync_install = false,
  highlight = {
    enable = true,
    disable = function(_, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<cr>",
      node_incremental = "<cr>",
      node_decremental = "<s-cr>",
    },
  },
})

local ft_to_parser = require("nvim-treesitter.parsers").filetype_to_parsername
ft_to_parser.zsh = "bash"
ft_to_parser.json = "jsonc"

require("dressing").setup({
  input = { insert_only = false, win_options = { winblend = 0 } },
  select = { nui = { win_options = { winblend = 0 } } },
  builtin = { win_options = { winblend = 0 } },
})

require("Comment").setup({
  toggler = {
    line = "<leader>/",
    block = "<leader>?",
  },
  opleader = {
    line = "<leader>/",
    block = "<leader>?",
  },
})

require("nvim-autopairs").setup({ check_ts = true })

local telescope = require("telescope")
local actions = require("telescope.actions")
telescope.setup({
  defaults = {
    file_ignore_patterns = { "^.git/" },
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<c-q>"] = actions.send_to_qflist,
        ["<m-q>"] = actions.send_selected_to_qflist,
      },
    },
    path_display = { "truncate" },
    layout_strategy = "vertical",
    preview = { filesize_limit = 1 }, -- 1 MB
  },
  pickers = {
    find_files = { hidden = true },
    live_grep = {
      mappings = {
        i = { ["<c-space>"] = actions.to_fuzzy_refine },
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
  },
})
telescope.load_extension("fzf")

require("hop").setup()

require("nvim-surround").setup({})

require("gitsigns").setup({})

local colors = require("gruvbox.palette").colors
local lualine_theme = {
  normal = {
    a = { bg = colors.light4, fg = colors.dark0, gui = "bold" },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark1, fg = colors.light4 },
  },
  insert = {
    a = { bg = colors.bright_blue, fg = colors.dark0, gui = "bold" },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark1, fg = colors.light4 },
  },
  visual = {
    a = { bg = colors.bright_orange, fg = colors.dark0, gui = "bold" },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark1, fg = colors.light4 },
  },
  replace = {
    a = { bg = colors.bright_red, fg = colors.dark0, gui = "bold" },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark1, fg = colors.light4 },
  },
  command = {
    a = { bg = colors.bright_purple, fg = colors.dark0, gui = "bold" },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark1, fg = colors.light4 },
  },
  terminal = {
    a = { bg = colors.bright_green, fg = colors.dark0, gui = "bold" },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark1, fg = colors.light4 },
  },
}
require("lualine").setup({
  sections = {
    lualine_c = { { "filename", path = 1 } },
  },
  options = {
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    theme = lualine_theme,
  },
})

require("completion").setup()

vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
