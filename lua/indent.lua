local M = {}

---@class VimIndentOptions
---@field expandtab boolean
---@field shiftwidth integer
---@field tabstop integer

---@class OkIndentConfig
---@field tab_width integer
---@field space_widths integer[]

---@param arr integer[]
---@return integer[]
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
  if #line < 2 then
    return false
  end
  return string.sub(line, 1, 1) == "\t"
end

---@param line string
---@param width integer
---@return boolean
local function detect_space(line, width)
  if #line < width + 1 then
    return false
  end
  return string.sub(line, 1, width) == string.rep(" ", width)
    and string.sub(line, width + 1, width + 1) ~= " "
end

---@param line string
---@param widths integer[] Must be sorted in descending order.
---@return integer?
local function detect_spaces(line, widths)
  for _, w in ipairs(widths) do
    if detect_space(line, w) then
      return w
    end
  end
end

---@param line string
---@param cfg OkIndentConfig
---@return VimIndentOptions?
local function detect_tab_or_spaces(line, cfg)
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

---@param line_count integer
---@param get_line fun(n: integer): string Returns the nth line (0-indexed)
---@return fun(): string?
local function iterate_over_lines(line_count, get_line)
  local i = 0
  return function()
    if i == line_count then
      return
    end
    local line = get_line(i)
    i = i + 1
    return line
  end
end

---@param line_iterator fun(): string?
---@param cfg OkIndentConfig
---@return VimIndentOptions?
local function find_first_indent(line_iterator, cfg)
  for line in line_iterator do
    local opts = detect_tab_or_spaces(line, cfg)
    if opts ~= nil then
      return opts
    end
  end
end

---@param bufnr integer
---@param max_line_len integer
---@return fun(): string?
local function iterate_over_buffer_lines(bufnr, max_line_len)
  return iterate_over_lines(vim.api.nvim_buf_line_count(bufnr), function(n)
    return vim.api.nvim_buf_get_text(bufnr, n, 0, n, max_line_len, {})[1]
  end)
end

---@param bufnr integer
---@param cfg OkIndentConfig
---@return VimIndentOptions?
M.detect = function(bufnr, cfg)
  cfg = {
    tab_width = cfg.tab_width,
    space_widths = sorted_descending(cfg.space_widths),
  }
  local max_space_width = cfg.space_widths[1]
  return find_first_indent(
    iterate_over_buffer_lines(bufnr, max_space_width + 1),
    cfg
  )
end

M.exported_for_testing = {
  detect_tab = detect_tab,
  detect_spaces = detect_spaces,
  detect_tab_or_spaces = detect_tab_or_spaces,
  find_first_indent = find_first_indent,
}

return M
