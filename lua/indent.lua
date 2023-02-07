local M = {}

---@class VimIndentOptions
---@field expandtab boolean
---@field shiftwidth integer
---@field tabstop integer

---@class OkIndentConfig
---@field tab_width integer
---@field space_widths integer[]

---@param arr number[]
---@return number[]
local function sorted_descending(arr)
  local res = {}
  for _, v in ipairs(arr) do
    table.insert(res, v)
  end
  table.sort(res, function(a, b)
    return a > b
  end)
  return res
end

---@param line string
---@return boolean
local function detect_tab(line)
  return string.sub(line, 1, 1) == "\t"
end

---@param s string
---@param n integer
---@return boolean
local function starts_with_n_spaces(s, n)
  return string.sub(s, 1, n) == string.rep(" ", n)
end

---@param line string
---@param widths integer[] Must be sorted in descending order.
---@return integer?
local function detect_spaces(line, widths)
  for _, w in ipairs(widths) do
    if starts_with_n_spaces(line, w) then
      return w
    end
  end
end

---@param line string
---@param cfg OkIndentConfig
---@return VimIndentOptions?
local function detect_opts(line, cfg)
  if detect_tab(line) then
    return {
      expandtab = false,
      shiftwidth = cfg.tab_width,
      tabstop = cfg.tab_width,
    }
  end
  local w = detect_spaces(line, cfg.space_widths)
  if w ~= nil then
    return { expandtab = true, shiftwidth = w, tabstop = w }
  end
end

---@param bufnr integer
---@param max_line_len integer
---@return fun(): string?
local function iterate_buf_lines(bufnr, max_line_len)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local i = 0
  return function()
    if i == line_count then
      return
    end
    local lines = vim.api.nvim_buf_get_text(bufnr, i, 0, i, max_line_len, {})
    if #lines ~= 1 then
      return
    end
    i = i + 1
    return lines[1]
  end
end

---@param bufnr integer
---@return VimIndentOptions?
M.detect = function(bufnr)
  ---@type OkIndentConfig
  local cfg = {
    tab_width = 4,
    space_widths = { 4, 2 },
  }
  local max_space_width = cfg.space_widths[1]
  for line in iterate_buf_lines(bufnr, max_space_width) do
    local opts = detect_opts(line, cfg)
    if opts ~= nil then
      return opts
    end
  end
end

return M
