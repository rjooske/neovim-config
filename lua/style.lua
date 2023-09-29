local M = {}

M.opt = {
  background = "dark",
  colorcolumn = "80",
  cursorline = true,
  expandtab = true,
  laststatus = 3,
  list = true,
  number = true,
  pumheight = 10,
  relativenumber = true,
  shiftwidth = 4,
  showmode = false,
  signcolumn = "yes",
  splitbelow = true,
  splitright = true,
  tabstop = 4,
}

M.signs = {
  DiagnosticSignError = " ",
  DiagnosticSignWarn = " ",
  DiagnosticSignInfo = " ",
  DiagnosticSignHint = " ",
}

---@param len integer
---@return string
local leadmultispace = function(len)
  return "│" .. string.rep(" ", len - 1)
end

---@class Listchars
---@field tab string
---@field trail string
---@field nbsp string
---@field leadmultispace string

---@param tab_size integer
---@return Listchars
M.listchars = function(tab_size)
  return {
    tab = "│ ",
    trail = "-",
    nbsp = "~",
    leadmultispace = leadmultispace(tab_size),
  }
end

local colors = require("gruvbox.palette").get_base_colors({}, nil, nil)

M.lualine_theme = {
  normal = {
    a = { bg = colors.fg4, fg = colors.bg0, gui = "bold" },
    b = { bg = colors.bg2, fg = colors.fg1 },
    c = { bg = colors.bg1, fg = colors.fg4 },
  },
  insert = {
    a = { bg = colors.blue, fg = colors.bg0, gui = "bold" },
    b = { bg = colors.bg2, fg = colors.fg1 },
    c = { bg = colors.bg1, fg = colors.fg4 },
  },
  visual = {
    a = { bg = colors.orange, fg = colors.bg0, gui = "bold" },
    b = { bg = colors.bg2, fg = colors.fg1 },
    c = { bg = colors.bg1, fg = colors.fg4 },
  },
  replace = {
    a = { bg = colors.red, fg = colors.bg0, gui = "bold" },
    b = { bg = colors.bg2, fg = colors.fg1 },
    c = { bg = colors.bg1, fg = colors.fg4 },
  },
  command = {
    a = { bg = colors.purple, fg = colors.bg0, gui = "bold" },
    b = { bg = colors.bg2, fg = colors.fg1 },
    c = { bg = colors.bg1, fg = colors.fg4 },
  },
  terminal = {
    a = { bg = colors.green, fg = colors.bg0, gui = "bold" },
    b = { bg = colors.bg2, fg = colors.fg1 },
    c = { bg = colors.bg1, fg = colors.fg4 },
  },
}

return M
