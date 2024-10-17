local M = {}

---@param filetype string
---@return string
local function filetype_to_formatter_name(filetype)
  if filetype == "rust" then
    return "rust_analyzer"
  elseif filetype == "svelte" then
    return "svelte"
  else
    return "null-ls"
  end
end

---@param bufnr integer Must be an explicit number and not 0.
M.format = function(bufnr)
  if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
    return
  end

  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  local name = filetype_to_formatter_name(filetype)
  vim.lsp.buf.format({
    bufnr = bufnr,
    timeout_ms = 5000,
    filter = function(client)
      return client.name == name
    end,
  })
end

return M
