local M = {}

---@param lines string[]
---@return integer
local function count_words(lines)
  local n = 0
  for _, line in ipairs(lines) do
    for _ in line:gmatch("%S+") do
      n = n + 1
    end
  end
  return n
end

---@param n integer
---@return string
local function word_or_words(n)
  if n == 1 then
    return "word"
  else
    return "words"
  end
end

---@param name string
---@return integer
local function mark_name_to_extmark_id(name)
  return name:byte(1, 1)
end

local namespace = vim.api.nvim_create_namespace("tally")

---@class MarkPosition
---@field row integer 0-indexed
---@field col integer 0-indexed

---@param a MarkPosition
---@param b MarkPosition
---@return boolean
local function mark_position_less_than(a, b)
  return a.row < b.row or a.col < b.col
end

---@param bufnr integer
---@param mark_name string
---@return MarkPosition | nil
local function nvim_buf_get_mark(bufnr, mark_name)
  local mark = vim.api.nvim_buf_get_mark(bufnr, mark_name)
  local row = mark[1]
  local col = mark[2]

  if row == 0 and col == 0 then
    return nil
  else
    return { row = row - 1, col = col }
  end
end

---@param bufnr integer
local function update(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

  local start_mark_name = "b"
  local end_mark_name = "e"

  local start_mark = nvim_buf_get_mark(bufnr, start_mark_name)
  local end_mark = nvim_buf_get_mark(bufnr, end_mark_name)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  if
    start_mark == nil
    or end_mark == nil
    or not mark_position_less_than(start_mark, end_mark)
    or line_count <= end_mark.row
  then
    return
  end

  local n = count_words(
    vim.api.nvim_buf_get_lines(bufnr, start_mark.row, end_mark.row, true)
  )

  vim.api.nvim_buf_set_extmark(bufnr, namespace, start_mark.row, start_mark.col, {
    id = mark_name_to_extmark_id(start_mark_name),
    end_row = start_mark.row,
    end_col = start_mark.col,
    virt_text = {
      {
        string.format(
          "'%s | Start of region | %d %s",
          start_mark_name,
          n,
          word_or_words(n)
        ),
        "Comment",
      },
    },
  })
  vim.api.nvim_buf_set_extmark(bufnr, namespace, end_mark.row, end_mark.col, {
    id = mark_name_to_extmark_id(end_mark_name),
    end_row = end_mark.row,
    end_col = end_mark.col,
    virt_text = {
      {
        string.format(
          "'%s | End of region | %d %s",
          end_mark_name,
          n,
          word_or_words(n)
        ),
        "Comment",
      },
    },
  })
end

M.setup = function()
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = vim.api.nvim_create_augroup("TallyUpdate", {}),
    pattern = "*:*",
    callback = function(args)
      update(args.buf)
    end,
  })
end

return M
