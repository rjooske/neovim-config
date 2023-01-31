local M = {}

---@class OkIndentOpts
---@field expandtab boolean
---@field shiftwidth integer

---@param bufnr integer
---@return fun(): string?
local function iterate_buf_lines(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local i = 0
  return function()
    if i == line_count then
      return
    end
    local lines = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, true)
    if #lines ~= 1 then
      return
    end
    i = i + 1
    return lines[1]
  end
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
---@param widths integer[]
---@return integer?
local function detect_spaces(line, widths)
  for _, w in ipairs(widths) do
    if starts_with_n_spaces(line, w) then
      return w
    end
  end
end

---@param line string
---@param widths integer[]
---@param prev_opts OkIndentOpts
---@return OkIndentOpts?
local function detect_opts(line, widths, prev_opts)
  if detect_tab(line) then
    return { expandtab = true, shiftwidth = prev_opts.shiftwidth }
  end
  local w = detect_spaces(line, widths)
  if w ~= nil then
    return { expandtab = false, shiftwidth = w }
  end
end

M.detect = function()
  local widths = { 2, 4 }
  for line in iterate_buf_lines(0) do
  end
end

M.detect()

return M
