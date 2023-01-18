vim.cmd.colorscheme("rjooske")

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

vim.g.mapleader = " "

vim.keymap.set("n", "<leader>w", ":w<cr>", { silent = true, desc = "Save" })
vim.keymap.set("n", "<leader>W", ":noautocmd w<cr>", { silent = true, desc = "Save without formatting" })
vim.keymap.set("n", "<leader>q", ":close<cr>", { silent = true, desc = "Close window except last one" })
vim.keymap.set("n", "<leader><leader>q", ":q<cr>", { silent = true, desc = "Close window" })
vim.keymap.set("n", "<leader><leader><leader>q", ":cq<cr>", { silent = true, desc = "Exit with error code" })
vim.keymap.set("n", "<esc>", function()
	vim.cmd("noh")
end)

vim.keymap.set({ "n", "v" }, "<leader>y", '"*y', { silent = true, desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>Y", '"*Y', { silent = true, desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"*p', { silent = true, desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>P", '"*P', { silent = true, desc = "Paste from system clipboard" })

vim.keymap.set("n", "<leader>bd", function()
	local buftype = vim.api.nvim_buf_get_option(0, "buftype")
	local force = buftype == "terminal"
	require("bufdelete").bufdelete(0, force)
end)
vim.keymap.set("n", "<leader>bs", ":BufferLineSortByDirectory<cr>", { silent = true })
vim.keymap.set("n", "H", ":BufferLineCyclePrev<cr>", { silent = true })
vim.keymap.set("n", "L", ":BufferLineCycleNext<cr>", { silent = true })
vim.keymap.set("n", "<c-h>", ":wincmd h<cr>", { silent = true })
vim.keymap.set("n", "<c-j>", ":wincmd j<cr>", { silent = true })
vim.keymap.set("n", "<c-k>", ":wincmd k<cr>", { silent = true })
vim.keymap.set("n", "<c-l>", ":wincmd l<cr>", { silent = true })

vim.keymap.set("t", "<c-h>", "<c-\\><c-n>:wincmd h<cr>", { silent = true })
vim.keymap.set("t", "<c-j>", "<c-\\><c-n>:wincmd j<cr>", { silent = true })
vim.keymap.set("t", "<c-k>", "<c-\\><c-n>:wincmd k<cr>", { silent = true })
vim.keymap.set("t", "<c-l>", "<c-\\><c-n>:wincmd l<cr>", { silent = true })
vim.keymap.set("t", "<esc>", "<c-\\><c-n>", { silent = true })

-- Bad code ahead
local prev_win = 0

vim.keymap.set({ "n", "i", "t" }, "<c-;>", function()
	local current_win = vim.api.nvim_get_current_win()
	if vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(current_win), "buftype") == "terminal" then
		vim.api.nvim_set_current_win(prev_win)
		prev_win = current_win
		return
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "buftype") == "terminal" then
			vim.api.nvim_set_current_win(win)
			prev_win = current_win
			vim.cmd("normal Ga")
			return
		end
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
			vim.api.nvim_set_current_buf(bufnr)
			vim.cmd("normal Ga")
			return
		end
	end

	vim.cmd("vs | te")
	vim.cmd("normal Ga")
end)
-- Bad code end

for k, v in pairs(require("style").opt) do
	vim.opt[k] = v
end

local style_augroup = vim.api.nvim_create_augroup("RjooskeStyle", {})
vim.api.nvim_create_autocmd("BufReadPost", {
	group = style_augroup,
	callback = function()
		vim.cmd.IndentOMatic()
		vim.opt.listchars = require("style").listchars(vim.opt.tabstop:get())
	end,
})

require("packer").startup(function(use)
	use("wbthomason/packer.nvim")

	use("dstein64/vim-startuptime")

	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("neovim/nvim-lspconfig")

	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = "nvim-lua/plenary.nvim",
	})
	use("jayp0521/mason-null-ls.nvim")

	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	use("onsails/lspkind.nvim")

	use("dcampos/nvim-snippy")
	use("dcampos/cmp-snippy")

	use("simrat39/rust-tools.nvim")

	-- use("ray-x/lsp_signature.nvim")

	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})
	use("stevearc/dressing.nvim")

	use("windwp/nvim-autopairs")
	use("numToStr/Comment.nvim")
	use("Darazaki/indent-o-matic")

	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
		},
	})

	use("nvim-tree/nvim-web-devicons")

	use({
		"phaazon/hop.nvim",
		branch = "v2", -- optional but strongly recommended
	})
	use({
		"kylechui/nvim-surround",
		tag = "*", -- Use for stability; omit to use `main` branch for the latest features
	})

	use("folke/which-key.nvim")

	use("lewis6991/gitsigns.nvim")

	use({ "akinsho/bufferline.nvim", tag = "v3.*", requires = "nvim-tree/nvim-web-devicons" })
	use("famiu/bufdelete.nvim")

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
	})

	use("tpope/vim-fugitive")
end)

-- Must be setup in this order
require("mason").setup({ ui = { border = "rounded" } })

local format = function(bufnr)
	vim.lsp.buf.format({
		bufnr = bufnr,
		timeout_ms = 5000,
		filter = function(client)
			-- -- Do not ask tsserver to format the code
			-- return client.name ~= "tsserver"
			return client.name == "null-ls"
		end,
	})
end

local on_attach = function(client, bufnr)
	-- Create a mapping local to this buffer
	local map = function(mode, lhs, rhs, opts)
		opts.buffer = bufnr
		vim.keymap.set(mode, lhs, rhs, opts)
	end

	if client.supports_method("textDocument/formatting") then
		map("n", "<leader>lf", function()
			format(bufnr)
		end, { desc = "Format" })

		-- Format on save
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				format(bufnr)
			end,
		})
	end

	-- if client.supports_method("textDocument/signatureHelp") then
	-- 	-- Show parameter names, types, etc
	-- 	require("lsp_signature").on_attach({
	-- 		toggle_key = "<c-k>",
	-- 	}, bufnr)
	-- end

	local diagnostic_float_opts = {
		source = "always",
		scope = "line",
		border = "rounded",
	}
	map("n", "gl", function()
		vim.diagnostic.open_float(diagnostic_float_opts)
	end, { desc = "Open diagnostics on the current line" })
	map("n", "]d", function()
		vim.diagnostic.goto_next({ float = diagnostic_float_opts })
	end, { desc = "Go to the next diagnostic" })
	map("n", "[d", function()
		vim.diagnostic.goto_prev({ float = diagnostic_float_opts })
	end, { desc = "Go to the previous diagnostic" })
	map("n", "K", vim.lsp.buf.hover, {})
	map("n", "gD", vim.lsp.buf.declaration, {})
	map("n", "gd", vim.lsp.buf.definition, {})
	map("n", "gi", vim.lsp.buf.implementation, {})
	map("n", "gr", vim.lsp.buf.references, {})
	map("n", "<space>D", vim.lsp.buf.type_definition, {})
	map("n", "<space>rn", vim.lsp.buf.rename, {})
	map("n", "<space>ca", vim.lsp.buf.code_action, {})
end

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
})

vim.diagnostic.config({
	severity_sort = true,
	float = {
		source = "always",
		scope = "line",
		border = "rounded",
	},
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- capabilities.offsetEncoding = { "utf-8" }
local lspconfig = require("lspconfig")
lspconfig.sumneko_lua.setup({
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
	capabilities = vim.tbl_extend("force", capabilities, { offsetEncoding = "utf-8" }),
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
require("lspconfig.ui.windows").default_options.border = "rounded"

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

		null_ls.builtins.diagnostics.selene,
		null_ls.builtins.formatting.stylua,

		null_ls.builtins.formatting.clang_format.with({
			extra_filetypes = { "arduino" },
		}),

		null_ls.builtins.diagnostics.eslint_d.with({ condition = eslint_condition }),
		-- null_ls.builtins.formatting.eslint_d.with({ condition = eslint_condition }),
		null_ls.builtins.code_actions.eslint_d.with({ condition = eslint_condition }),

		null_ls.builtins.formatting.prettierd,

		-- null_ls.builtins.diagnostics.flake8,
		-- null_ls.builtins.diagnostics.pylint,
		null_ls.builtins.formatting.black,
		null_ls.builtins.formatting.isort,

		null_ls.builtins.formatting.rustfmt,

		null_ls.builtins.formatting.goimports,

		null_ls.builtins.formatting.taplo,
	},
})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"c",
		"cpp",
		"css",
		"gitcommit",
		"gitignore",
		"html",
		"java",
		"javascript",
		"json",
		"jsonc",
		"lua",
		"make",
		"markdown",
		"proto",
		"python",
		"rust",
		"scss",
		"toml",
		"typescript",
		"vim",
	},
	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,
	highlight = {
		enable = true,
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
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.wo.foldenable = false

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

local autopairs = require("nvim-autopairs")
autopairs.setup({ check_ts = true })

require("indent-o-matic").setup({})
-- Do not run indent-o-matic automatically
vim.api.nvim_create_autocmd("BufReadPre", {
	once = true,
	callback = function()
		vim.api.nvim_del_augroup_by_name("indent_o_matic")
	end,
})

local telescope = require("telescope")
local actions = require("telescope.actions")
telescope.setup({
	defaults = {
		file_ignore_patterns = { "^%.git/" },
		mappings = {
			i = {
				["<esc>"] = actions.close,
			},
		},
	},
	pickers = {
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

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>o", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>O", builtin.oldfiles, { desc = "Recently opened files" })
vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep CWD" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Grep buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
vim.keymap.set("n", "<leader>fs", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current buffer" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Fuzzy find diagnostics" })
vim.keymap.set("n", "<leader>fy", builtin.lsp_dynamic_workspace_symbols, { desc = "Query for workspace symbols" })
vim.keymap.set("n", "<leader>:", builtin.command_history, {})

local hop = require("hop")
local hop_hint = require("hop.hint")
hop.setup()
vim.keymap.set({ "n", "v" }, "<leader><leader>w", function()
	hop.hint_words({ direction = hop_hint.HintDirection.AFTER_CURSOR })
end)
vim.keymap.set({ "n", "v" }, "<leader><leader>b", function()
	hop.hint_words({ direction = hop_hint.HintDirection.BEFORE_CURSOR })
end)
vim.keymap.set({ "n", "v" }, "<leader><leader>j", function()
	hop.hint_lines_skip_whitespace({ direction = hop_hint.HintDirection.AFTER_CURSOR })
end)
vim.keymap.set({ "n", "v" }, "<leader><leader>k", function()
	hop.hint_lines_skip_whitespace({ direction = hop_hint.HintDirection.BEFORE_CURSOR })
end)
vim.keymap.set({ "n", "v" }, "<leader>h", function()
	require("hop").hint_char2({})
end)

require("nvim-surround").setup({})

require("gitsigns").setup({})

require("bufferline").setup({
	highlights = {
		buffer_selected = { ctermbg = 0 },
		indicator_selected = { ctermbg = 0 },
		separator_selected = { ctermbg = 0 },
		close_button_selected = { ctermbg = 0 },
		duplicate_selected = { ctermbg = 0 },
		modified_selected = { ctermbg = 0 },
	},
})

require("lualine").setup({
	sections = {
		lualine_b = {
			{ "branch" },
			{
				"diff",
				colored = true,
				diff_color = {
					added = "DiffAdd",
					modified = "DiffChange",
					removed = "DiffDelete",
				},
			},
			{
				"diagnostics",
				diagnostics_color = {
					error = "DiagnosticError",
					warn = "DiagnosticWarn",
					info = "DiagnosticInfo",
					hint = "DiagnosticHint",
				},
			},
		},
		lualine_c = {
			{
				"filename",
				path = 1,
			},
		},
	},
	options = {
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		theme = {
			normal = { a = { gui = "standout" }, b = { bg = 0 }, c = { bg = 0 } },
			insert = { a = { fg = 4, gui = "standout" }, b = { bg = 0 }, c = { bg = 0 } },
			visual = { a = { fg = 3, gui = "standout" }, b = { bg = 0 }, c = { bg = 0 } },
			terminal = { a = { fg = 2, gui = "standout" }, b = { bg = 0 }, c = { bg = 0 } },
			command = { a = { fg = 5, gui = "standout" }, b = { bg = 0 }, c = { bg = 0 } },
		},
	},
})

require("completion").setup()

require("which-key").setup()
