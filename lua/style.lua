local M = {}

local colors = require("gruvbox").palette

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

M.lualine_theme = {
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

return M
