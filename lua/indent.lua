local M = {}

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
---@return integer
local function detect_spaces(line, widths)
  for _, w in ipairs(widths) do
    if starts_with_n_spaces(line, w) then
      return w
    end
  end
  return 0
end

local function detect(cfg, line) end

M.detect = function()
  for line in iterate_buf_lines(0) do
    local s = detect_spaces(line, { 2, 4 })
    if s == nil then
      s = 0
    end
    print(s .. " " .. line)
  end
end

M.detect()

return M
