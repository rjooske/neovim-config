local M = {}

M.opt = {
  colorcolumn = "80",
  cursorline = true,
  expandtab = true,
  laststatus = 3,
  list = true,
  number = true,
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

return M
