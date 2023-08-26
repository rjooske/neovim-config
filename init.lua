require("paq")({
  "savq/paq-nvim",

  -- Common dependencies
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",

  -- Language servers
  "neovim/nvim-lspconfig",
  "jose-elias-alvarez/null-ls.nvim",
  "simrat39/rust-tools.nvim",

  -- Completion
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/nvim-cmp",
  "dcampos/nvim-snippy",
  "dcampos/cmp-snippy",
  "onsails/lspkind.nvim",

  -- Editing
  "phaazon/hop.nvim",
  "numToStr/Comment.nvim",
  "kylechui/nvim-surround",
  "Wansmer/treesj",

  -- Telescope
  "nvim-telescope/telescope.nvim",
  { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },

  -- Git
  "tpope/vim-fugitive",
  "lewis6991/gitsigns.nvim",

  -- Colorscheme
  "ellisonleao/gruvbox.nvim",

  -- Bling
  {
    "nvim-treesitter/nvim-treesitter",
    run = function()
      vim.cmd("TSUpdate")
    end,
  },
  "SmiteshP/nvim-navic",
  "stevearc/dressing.nvim",
  "nvim-lualine/lualine.nvim",

  -- Misc
  "famiu/bufdelete.nvim",
  "dstein64/vim-startuptime",
  "mrjones2014/smart-splits.nvim",
})

require("gruvbox").setup({
  overrides = {
    LspReferenceText = { standout = true },
    LspReferenceRead = { standout = true },
    LspReferenceWrite = { standout = true, underline = true },
  },
})
vim.cmd.colorscheme("gruvbox")

vim.go.backupcopy = "yes"

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.go.mousescroll = "ver:1,hor:1"

vim.g.mapleader = require("keymap").leader
for _, v in ipairs(require("keymap").keymaps) do
  local opts = { silent = true, desc = v.desc }
  vim.keymap.set(v.mode, v.lhs, v.rhs, opts)
end

vim.keymap.set("n", "<leader>d", function()
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

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("DetectIndent", {}),
  callback = function(event)
    local buftype = vim.api.nvim_buf_get_option(event.buf, "buftype")
    if buftype ~= "" then
      return
    end
    local opts = require("indent").detect(
      event.buf,
      { tab_width = 4, space_widths = { 2, 4 } }
    )
    if opts == nil then
      return
    end
    for k, v in pairs(opts) do
      vim.bo[event.buf][k] = v
    end
    vim.opt_local.listchars = require("style").listchars(opts.tabstop)
  end,
})

---@param filetype string
---@return string
local function filetype_to_formatter_name(filetype)
  if filetype == "rust" then
    return "rust_analyzer"
  else
    return "null-ls"
  end
end

---@param bufnr integer
local function format(bufnr)
  if #vim.lsp.get_active_clients({ bufnr = bufnr }) == 0 then
    return
  end

  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local name = filetype_to_formatter_name(filetype)
  vim.lsp.buf.format({
    bufnr = bufnr,
    timeout_ms = 5000,
    filter = function(client)
      return client.name == name
    end,
  })
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("FormatOnSave", {}),
  callback = function(args)
    format(args.buf)
  end,
})

vim.keymap.set("n", "<Leader>lf", function()
  format(0)
end, { desc = "Format" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspPreferences", {}),
  callback = function(args)
    -- Make `gq` work by removing `formatexpr` that gets added automatically
    vim.bo[args.buf].formatexpr = nil

    -- Disable semantic tokens
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

local function on_attach(client, bufnr)
  -- Create a mapping local to this buffer
  local function map(mode, lhs, rhs, opts)
    opts.buffer = bufnr
    vim.keymap.set(mode, lhs, rhs, opts)
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
lspconfig.lua_ls.setup({ on_attach = on_attach, capabilities = capabilities })
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
lspconfig.hls.setup({ on_attach = on_attach, capabilities = capabilities })
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
lspconfig.html.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.cssls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.jsonls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.svelte.setup({ on_attach = on_attach, capabilities = capabilities })

local rust_tools = require("rust-tools")
rust_tools.setup({
  server = {
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = { command = "clippy" },
        inlayHints = { locationLinks = false },
      },
      -- https://users.rust-lang.org/t/how-to-disable-rust-analyzer-proc-macro-warnings-in-neovim/53150/5
      diagnostics = {
        enable = true,
        disabled = { "unresolved-proc-macro" },
        enableExperimental = true,
      },
    },
    on_attach = on_attach,
    capabilities = capabilities,
  },
})

local eslint_condition = function(utils)
  return utils.root_has_file({
    ".git",
    -- https://eslint.org/docs/latest/user-guide/configuring/configuration-files-new
    "eslint.config.js",
    -- https://eslint.org/docs/user-guide/configuring/configuration-files#configuration-file-formats
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
  }) and vim.fs.basename(vim.loop.cwd()) ~= "campusTAKESHI"
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

    null_ls.builtins.diagnostics.eslint_d.with({
      extra_filetypes = { "svelte" },
      condition = eslint_condition,
    }),
    null_ls.builtins.code_actions.eslint_d.with({
      extra_filetypes = { "svelte" },
      condition = eslint_condition,
    }),

    null_ls.builtins.formatting.prettierd.with({
      extra_filetypes = { "svelte" },
    }),

    null_ls.builtins.diagnostics.flake8.with({
      extra_args = { "--extend-ignore", "E203,E741" },
    }),
    null_ls.builtins.formatting.black.with({
      extra_args = { "--line-length", "79" },
    }),
    null_ls.builtins.formatting.isort,

    null_ls.builtins.formatting.goimports,
    null_ls.builtins.diagnostics.golangci_lint,

    null_ls.builtins.formatting.fourmolu,
    null_ls.builtins.formatting.cabal_fmt,

    null_ls.builtins.formatting.taplo,
  },
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
    "cmake",
    "comment",
    "cpp",
    "css",
    "dart",
    "diff",
    "dockerfile",
    "fennel",
    "gitcommit",
    "gitignore",
    "go",
    "gomod",
    "haskell",
    "html",
    "java",
    "javascript",
    "jsdoc",
    "jsonc",
    "latex",
    "lua",
    "luadoc",
    "make",
    "markdown",
    "markdown_inline",
    "proto",
    "python",
    "regex",
    "rust",
    "scss",
    "svelte",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
    -- "sql", -- a bit buggy
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
  indent = { enable = true, disable = { "python" } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<Plug>TreesitterSelectMore",
      node_incremental = "<Plug>TreesitterSelectMore",
      node_decremental = "<Plug>TreesitterSelectLess",
    },
  },
})

---@param s string
---@param pattern string
---@return boolean
local function string_ends_with(s, pattern)
  return pattern == "" or s:sub(-#pattern) == pattern
end

vim.keymap.set({ "n", "x" }, "<CR>", function()
  local name = vim.api.nvim_buf_get_name(0)
  if string_ends_with(name, "[Command Line]") then
    return "<CR>"
  else
    return "<Plug>TreesitterSelectMore"
  end
end, { expr = true })
vim.keymap.set("x", "<S-CR>", "<Plug>TreesitterSelectLess")

vim.treesitter.language.register("bash", { "sh", "zsh" })
vim.treesitter.language.register("jsonc", "json")

require("dressing").setup({
  input = { insert_only = false, win_options = { winblend = 0 } },
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

local actions = require("telescope.actions")
local telescope = require("telescope")
telescope.setup({
  defaults = {
    file_ignore_patterns = { "^.git/" },
    mappings = {
      i = {
        ["<Esc>"] = actions.close,
        ["<C-q>"] = actions.send_to_qflist,
        ["<M-q>"] = actions.send_selected_to_qflist,
      },
    },
    path_display = { "truncate" },
    -- layout_strategy = "vertical",
    preview = { filesize_limit = 1 }, -- 1 MB
  },
  pickers = {
    find_files = { hidden = true },
    live_grep = {
      mappings = {
        i = { ["<c-space>"] = actions.to_fuzzy_refine },
      },
    },
    buffers = { mappings = { i = { ["<C-r>"] = actions.delete_buffer } } },
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

require("gitsigns").setup({ update_debounce = 1000 })

require("lualine").setup({
  sections = {
    lualine_c = { { "filename", path = 1 } },
  },
  options = {
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    theme = require("style").lualine_theme,
  },
})

require("completion").setup()

vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

require("tally").setup()

local treesj = require("treesj")
treesj.setup({ use_default_keymaps = false, max_join_length = math.huge })

require("smart-splits").setup({ at_edge = "stop" })
