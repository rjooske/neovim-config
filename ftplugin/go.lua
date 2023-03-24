---@param bufnr integer
---@return string?
local function package_name(bufnr)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local f = io.popen("go list " .. vim.fn.shellescape(dir))
  if f == nil then
    return
  end
  local name = vim.fn.trim(f:read("*a"))
  f:close()
  return name
end

vim.api.nvim_buf_create_user_command(0, "GoYankPackageName", function()
  local name = package_name(0)
  if name ~= nil then
    vim.fn.setreg("*", name, "c")
  end
end, {})
