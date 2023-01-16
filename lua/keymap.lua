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
		rhs = ":w<cr>",
		desc = "Save",
	},
	{
		mode = "n",
		lhs = "<leader>W",
		rhs = ":noautocmd w<cr>",
		desc = "Save without formatting",
	},
	{
		mode = "n",
		lhs = "<leader>q",
		rhs = ":close<cr>",
		desc = "Close window except last one",
	},
	{
		mode = "n",
		lhs = "<leader><leader>q",
		rhs = ":q<cr>",
		desc = "Close window",
	},
	{
		mode = "n",
		lhs = "<leader>Q",
		rhs = ":cq<cr>",
		desc = "Exit with error code",
	},
	{
		mode = "n",
		lhs = "<esc>",
		rhs = ":noh<cr>",
		desc = "Clear search highlights",
	},
}

return M
