local M = {}

---@class VimIndentOptions
---@field expandtab boolean
---@field shiftwidth integer
---@field softtabstop integer
---@field tabstop integer

---@class OkIndentConfig
---@field tab_width integer
---@field space_widths integer[]

---@param line string
---@return boolean
local function tab_indented(line)
  if #line < 2 then
    return false
  end
  return string.sub(line, 1, 1) == "\t"
end

---@param line string
---@return integer
local function space_indent_size(line)
  local _, last = line:find("^ *")
  return last or 0
end

---@param config OkIndentConfig
---@param lines fun(): string?
---@return VimIndentOptions?
local function detect(config, lines)
  ---@type table<integer, boolean>
  local step_size_to_expected = {}
  for _, n in ipairs(config.space_widths) do
    step_size_to_expected[n] = true
  end

  ---@type table<integer, integer>
  local step_size_to_count = {}
  local last_space_indent_size = 0
  for line in lines do
    if tab_indented(line) then
      return {
        expandtab = false,
        shiftwidth = config.tab_width,
        softtabstop = config.tab_width,
        tabstop = config.tab_width,
      }
    end
    local n = space_indent_size(line)
    local step_size = math.abs(n - last_space_indent_size)
    if step_size ~= 0 then
      step_size_to_count[step_size] = (step_size_to_count[step_size] or 0) + 1
    end
    last_space_indent_size = n
  end

  local best_step_size = nil
  local best_count = 0
  for step_size, count in pairs(step_size_to_count) do
    if count > best_count and step_size_to_expected[step_size] then
      best_step_size = step_size
      best_count = count
    end
  end

  if best_step_size == nil then
    return nil
  else
    return {
      expandtab = true,
      shiftwidth = best_step_size,
      softtabstop = best_step_size,
      tabstop = best_step_size,
    }
  end
end

---@param bufnr integer
---@return fun(): string?
local function buffer_non_empty_lines(bufnr)
  ---@type integer
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local i = 0
  return function()
    local line = ""
    while line == "" do
      if i == line_count then
        return
      end
      line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, true)[1]
      i = i + 1
    end
    return line
  end
end

---@param bufnr integer
---@param config OkIndentConfig
---@return VimIndentOptions?
M.detect = function(bufnr, config)
  return detect(config, buffer_non_empty_lines(bufnr))
end

return M
