require("paq")({
  "savq/paq-nvim",

  -- Common dependencies
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",

  -- Language servers
  "neovim/nvim-lspconfig",
  "nvimtools/none-ls.nvim",
  "nvimtools/none-ls-extras.nvim",

  -- TypeScript
  "marilari88/twoslash-queries.nvim",

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
  "numToStr/Comment.nvim",
  "kylechui/nvim-surround",
  "Wansmer/treesj",

  -- Telescope
  "nvim-telescope/telescope.nvim",
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Git
  "tpope/vim-fugitive",
  "lewis6991/gitsigns.nvim",

  -- Colorscheme
  "ellisonleao/gruvbox.nvim",

  -- Bling
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      vim.cmd("TSUpdate")
    end,
  },
  "SmiteshP/nvim-navic",
  "stevearc/dressing.nvim",
  "nvim-lualine/lualine.nvim",

  -- Misc
  "famiu/bufdelete.nvim",
  "dstein64/vim-startuptime",
  "willothy/flatten.nvim",
})

local my_augroup = vim.api.nvim_create_augroup("MyAugroup", { clear = true })

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
  local opts = { silent = true, desc = v.desc, expr = v.expr }
  vim.keymap.set(v.mode, v.lhs, v.rhs, opts)
end

vim.keymap.set("n", "<leader>d", function()
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  local force = buftype == "terminal" or filetype == "netrw"
  require("bufdelete").bufdelete(0, force)
end)

for k, v in pairs(require("style").opt) do
  vim.opt[k] = v
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = my_augroup,
  callback = function(event)
    local buftype =
      vim.api.nvim_get_option_value("buftype", { buf = event.buf })
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

vim.api.nvim_create_autocmd("BufWritePre", {
  group = my_augroup,
  callback = function(args)
    require("format").format(args.buf)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = my_augroup,
  callback = function(args)
    for _, v in ipairs(require("keymap").lsp_keymaps) do
      vim.keymap.set(
        v.mode,
        v.lhs,
        v.rhs,
        { silent = true, desc = v.desc, expr = v.expr, buffer = args.buf }
      )
    end

    -- Make `gq` work by removing `formatexpr` that gets added automatically
    vim.bo[args.buf].formatexpr = nil

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    assert(client ~= nil, "Failed to get LSP client")

    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, args.buf)
    end

    -- Disable semantic tokens
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

vim.diagnostic.config({
  signs = false,
  severity_sort = true,
  float = {
    source = true,
    scope = "line",
  },
  virtual_text = true,
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--clang-tidy",
    "--background-index",
    "--offset-encoding=utf-8",
    -- This is a whitelist of binaries clangd is allowed to run to find where
    -- the system header files are (e.g. stdio.h, vector.h).
    -- /opt/homebrew/bin/arm-none-eabi-gcc: Used for raspberry pi pico
    -- development on macOS.
    "--query-driver=/opt/homebrew/bin/arm-none-eabi-gcc",
  },
})
vim.lsp.config("ts_ls", {
  settings = {
    -- https://github.com/typescript-language-server/typescript-language-server/blob/b224b878652438bcdd639137a6b1d1a6630129e4/docs/configuration.md?plain=1#L187
    completions = { completeFunctionCalls = true },
  },
  on_attach = function(client, bufnr)
    local twoslash_queries = require("twoslash-queries")
    twoslash_queries.setup({ multi_line = true, is_enabled = true })
    twoslash_queries.attach(client, bufnr)
  end,
})
vim.lsp.config("rust_analyzer", {
  settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
})
vim.lsp.enable({
  "lua_ls",
  "clangd",
  "pyright",
  "ts_ls",
  "hls",
  "gopls",
  "jdtls",
  "html",
  "emmet_language_server",
  "cssls",
  "jsonls",
  "svelte",
  "ocamllsp",
  "rust_analyzer",
  "texlab",
  "taplo",
})

local eslint_condition = function(utils)
  return utils.root_has_file({
    -- https://eslint.org/docs/latest/use/configure/configuration-files#configuration-file
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts",
    "eslint.config.mts",
    "eslint.config.cts",
    -- https://eslint.org/docs/latest/use/configure/configuration-files-deprecated
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
  }) and vim.fs.basename(vim.uv.cwd())
end

local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.selene.with({
      condition = function(utils)
        return utils.root_has_file({ "selene.toml" })
      end,
    }),

    null_ls.builtins.formatting.clang_format.with({
      extra_filetypes = { "arduino", "glsl" },
    }),

    require("none-ls.diagnostics.eslint_d").with({
      extra_filetypes = { "svelte" },
      condition = eslint_condition,
      method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
    }),
    require("none-ls.code_actions.eslint_d").with({
      extra_filetypes = { "svelte" },
      condition = eslint_condition,
      method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
    }),

    null_ls.builtins.formatting.prettierd.with({
      extra_filetypes = { "svelte" },
    }),

    require("none-ls.diagnostics.flake8").with({
      extra_args = { "--extend-ignore", "E203,E741" },
    }),
    null_ls.builtins.formatting.black.with({
      extra_args = { "--line-length", "79" },
    }),
    null_ls.builtins.formatting.isort,

    null_ls.builtins.formatting.goimports,

    null_ls.builtins.formatting.ocamlformat,
  },
})

require("nvim-treesitter.configs").setup({
  ensure_installed = "all",
  sync_install = false,
  highlight = {
    enable = true,
    disable = function(_, buf)
      local max_filesize = 1 * 1024 * 1024 -- 1MB
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
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

vim.keymap.set({ "n", "x" }, "<CR>", function()
  if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "" then
    return "<Plug>TreesitterSelectMore"
  else
    return "<CR>"
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
    find_files = { follow = true, hidden = true },
    live_grep = {
      mappings = {
        i = { ["<c-space>"] = actions.to_fuzzy_refine },
      },
    },
    buffers = { mappings = { i = { ["<C-h>"] = actions.delete_buffer } } },
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

local treesj = require("treesj")
treesj.setup({ use_default_keymaps = false, max_join_length = math.huge })

require("flatten").setup({})

vim.api.nvim_create_user_command("YankPathAbsolute", function()
  vim.fn.setreg("*", vim.fn.expand("%:p"), "c")
end, { desc = "Yank the absolute path to the current file" })

vim.api.nvim_create_user_command("YankPathRelative", function()
  vim.fn.setreg("*", vim.fn.expand("%:~:."), "c")
end, { desc = "Yank the relative path from the cwd to the current file" })

---@param key string
---@return string
local function jump_with_mark(key)
  if vim.v.count1 > 1 then
    return "m'" .. vim.v.count1 .. key
  else
    return key
  end
end

vim.keymap.set({ "n", "x" }, "j", function()
  return jump_with_mark("j")
end, { expr = true })
vim.keymap.set({ "n", "x" }, "k", function()
  return jump_with_mark("k")
end, { expr = true })
