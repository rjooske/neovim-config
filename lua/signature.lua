local M = {}

---@generic T, U
---@param arr T[]
---@param f fun(t: T): U
---@return U[]
local function array_map(arr, f)
  local res = {}
  for i, v in ipairs(arr) do
    res[i] = f(v)
  end
  return res
end

---@generic T, U
---@param t table<T, U>
---@return U
local function table_first_value(t)
  for _, v in pairs(t) do
    return v
  end
end

---@generic T
---@param t table<unknown, T>
---@return T[]
local function table_values(t)
  local res = {}
  for _, v in pairs(t) do
    table.insert(res, v)
  end
  return res
end

---@generic T
---@param arr T[][]
---@return T[]
local function array_flatten(arr)
  local res = {}
  for _, a in ipairs(arr) do
    for _, e in ipairs(a) do
      table.insert(res, e)
    end
  end
  return res
end

local example1 = {
  {
    result = {
      signatures = {
        {
          activeParameter = 0,
          label = "function M.signature(window: integer)",
          parameters = { {
            label = { 21, 36 },
          } },
        },
      },
    },
  },
}

local example2 = {
  [3] = {
    result = {
      activeParameter = 0,
      activeSignature = 0,
      signatures = {
        {
          documentation = "This one takes no parameters",
          label = "foo() -> int",
          parameters = {},
        },
        {
          documentation = "This one takes an int",
          label = "foo(int) -> int",
          parameters = { {
            label = { 4, 7 },
          } },
        },
        {
          documentation = "This one takes a float",
          label = "foo(float) -> int",
          parameters = { {
            label = { 4, 9 },
          } },
        },
      },
    },
  },
}

local hls = {
  inactive_signature = {
    name = "OkSignatureInactiveSignature",
    default = { link = "Comment" },
  },
  active_signature = {
    name = "OkSignatureActiveSignature",
    default = {},
  },
  active_parameter = {
    name = "OkSignatureActiveParameter",
    default = { link = "Visual" },
  },
}

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_signatureHelp

---@alias MarkupKind "plaintext" | "markdown"

---@class MarkupContent
---@field kind MarkupKind
---@field value string

---@class ParameterInformation
---@field label string | integer[]
---@field documentation? string | MarkupContent

---@class SignatureInformation
---@field label string
---@field documentation? string | MarkupContent
---@field parameters? ParameterInformation[]
---@field activeParameter? integer

---@class SignatureHelp
---@field signatures SignatureInformation[]
---@field activeSignature? integer
---@field activeParameter? integer

---@alias SignatureHelpResponse table<integer, { result: SignatureHelp }>

---@class OkRange
---@field first integer 1-indexed
---@field last integer 1-indexed

---@class OkParameter
---@field label_range OkRange
---@field documentation? string

---@class OkSignature
---@field label string
---@field parameters OkParameter[]
---@field documentation? string

---@class OkSignatureHelp
---@field signatures OkSignature[]
---@field active_signature_index integer 1-indexed
---@field active_parameter_index integer 1-indexed

---@class OkStateIdle
---@field kind "idle"

---@class OkStateWaiting
---@field kind "waiting"

---@class OkStateAvailable
---@field kind "available"
---@field help OkSignatureHelp

---@alias OkState OkStateIdle | OkStateWaiting | OkStateAvailable

---@class HlRange
---@field hl string Name of the highlight group
---@field first integer 1-indexed
---@field last integer 1-indexed

---@class HlRow
---@field content string
---@field hl_ranges HlRange[]

---@param content string
---@return HlRow
local function clean(content)
  return { content = content, hl_ranges = {} }
end

---@param hl string
---@param content string
---@return HlRow
local function monochrome(hl, content)
  return {
    content = content,
    hl_ranges = { { hl = hl, first = 1, last = #content } },
  }
end

---@generic T: table
---@param t T
---@return T
local function table_clone(t)
  local new = {}
  for k, v in pairs(t) do
    new[k] = v
  end
  return new
end

---@param a HlRow
---@param b HlRow
---@return HlRow
local function concat(a, b)
  local new_ranges = {}

  for _, r in ipairs(a.hl_ranges) do
    table.insert(new_ranges, table_clone(r))
  end
  for _, r in ipairs(b.hl_ranges) do
    table.insert(new_ranges, {
      hl = r.hl,
      first = r.first + #a.content,
      last = r.last + #a.content,
    })
  end

  return {
    content = a.content .. b.content,
    hl_ranges = new_ranges,
  }
end

---@param si SignatureInformation
---@param pi ParameterInformation
---@return OkRange
local function new_ok_parameter_label_range(si, pi)
  local label = pi.label
  if type(label) == "string" then
    local f, l = si.label:find(label, 0, true)
    return { first = f, last = l }
  else
    return { first = label[1] + 1, last = label[2] }
  end
end

---@param pi ParameterInformation
---@return string?
local function new_ok_parameter_documentation(pi)
  local doc = pi.documentation
  if doc == nil then
    return nil
  end
  if type(doc) == "string" then
    return doc
  else
    return doc.value
  end
end

---@param si SignatureInformation
---@param pi ParameterInformation
---@return OkParameter
local function new_ok_parameter(si, pi)
  return {
    label_range = new_ok_parameter_label_range(si, pi),
    documentation = new_ok_parameter_documentation(pi),
  }
end

---@param si SignatureInformation
---@return OkParameter[]
local function new_ok_parameters(si)
  local res = {}
  for i, pi in ipairs(si.parameters) do
    res[i] = new_ok_parameter(si, pi)
  end
  return res
end

---@param si SignatureInformation
---@return string?
local function new_ok_signature_documentation(si)
  local doc = si.documentation
  if doc == nil then
    return nil
  end
  if type(doc) == "string" then
    return doc
  else
    return doc.value
  end
end

---@param si SignatureInformation
---@return OkSignature
local function new_ok_signature(si)
  return {
    label = si.label,
    parameters = new_ok_parameters(si),
    documentation = new_ok_signature_documentation(si),
  }
end

---@param sh SignatureHelp
---@return OkSignature[]
local function new_ok_signatures(sh)
  local res = {}
  for i, si in ipairs(sh.signatures) do
    res[i] = new_ok_signature(si)
  end
  return res
end

---@param sh SignatureHelp
---@return integer?
local function find_active_signature_index(sh)
  if sh.signatures == nil or #sh.signatures == 0 then
    return
  end
  if sh.activeSignature ~= nil then
    return sh.activeSignature + 1
  end
  return 1
end

---@param sh SignatureHelp
---@param active_signature_index integer
---@return integer?
local function find_active_parameter_index(sh, active_signature_index)
  if sh.activeParameter ~= nil then
    return sh.activeParameter + 1
  end
  local ap = sh.signatures[active_signature_index].activeParameter
  if ap ~= nil then
    return ap + 1
  end
end

---@param sh SignatureHelp
---@return OkStateAvailable?
local function new_ok_state_available(sh)
  local asi = find_active_signature_index(sh)
  if asi == nil then
    return
  end
  ---@cast asi -nil
  local api = find_active_parameter_index(sh, asi)
  if api == nil then
    api = 1
  end
  ---@cast api -nil
  return {
    kind = "available",
    help = {
      signatures = new_ok_signatures(sh),
      active_signature_index = asi,
      active_parameter_index = api,
    },
  }
end

---@param s OkSignature
---@param p OkParameter
---@return string
local function ok_parameter_to_string(s, p)
  local label = string.sub(s.label, p.label_range.first, p.label_range.last)
  local doc = p.documentation and " " .. p.documentation or ""
  return label .. doc
end

---@param s OkSignature
---@return string
local function ok_parameters_to_string(s)
  ---@type string[]
  local lines = {}
  for _, p in ipairs(s.parameters) do
    table.insert(lines, ok_parameter_to_string(s, p))
  end
  return table.concat(lines, "\n")
end

---@param sh OkSignatureHelp
---@return string[]
local function ok_signature_help_labels(sh)
  ---@type string[]
  local res = {}
  for i, s in ipairs(sh.signatures) do
    if i == sh.active_signature_index then
      table.insert(res, "[ " .. s.label .. " ]")
    else
      table.insert(res, s.label)
    end
  end
  return res
end

---@param sh OkSignatureHelp
---@return string
local function ok_signature_help_to_string(sh)
  local active = sh.signatures[sh.active_signature_index]
  local params = ok_parameters_to_string(active)
  local labels = ok_signature_help_labels(sh)
  if active.documentation ~= nil then
    return active.documentation
      .. "\n"
      .. params
      .. "\n"
      .. table.concat(labels, "\n")
  else
    return params .. "\n" .. table.concat(labels, "\n")
  end
end

local augroup = vim.api.nvim_create_augroup("OkSignature", {})
local namespace = vim.api.nvim_create_namespace("OkSignature")

---@type OkState
local state = { kind = "idle" }
---@type integer?
local window = nil

local function log_env(f)
  local text = ""
  local function log(v)
    if type(v) == "string" then
      text = text .. v .. "\n"
    else
      text = text .. vim.inspect(v) .. "\n"
    end
  end
  f(log)
  -- vim.notify(text)
end

local function make_state_idle()
  state = { kind = "idle" }
  if window ~= nil then
    vim.api.nvim_win_close(window, true)
    window = nil
  end
end

---@param src string
---@param pattern string
---@return string[]
local function string_split(src, pattern)
  src = src .. pattern
  ---@type string[]
  local res = {}
  local seen_index = 0
  while true do
    local first, last = string.find(src, pattern, seen_index + 1, true)
    if first == nil or last == nil then
      break
    end
    table.insert(res, string.sub(src, seen_index + 1, first - 1))
    seen_index = last
  end
  return res
end

---@param sh OkSignatureHelp
local function make_state_available(sh)
  -- if state.kind ~= "idle" then
  --   return
  -- end
  state = { kind = "available", help = sh }
  local rows = string_split(ok_signature_help_to_string(sh), "\n")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, rows)
  vim.highlight.range(
    buf,
    namespace,
    hls.inactive_signature.name,
    { 1, 1 },
    { 1, 10 },
    {}
  )
  window = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    anchor = "SW",
    row = -1,
    col = 0,
    width = 100,
    height = 30,
    style = "minimal",
    noautocmd = true,
  })
  vim.api.nvim_win_set_hl_ns(window, namespace)
end

vim.api.nvim_create_autocmd("ModeChanged", {
  group = augroup,
  pattern = "i:*",
  callback = function()
    -- make_state_idle()
  end,
})

vim.keymap.set("n", "<leader>k", function()
  log_env(function(log)
    local req = vim.lsp.util.make_position_params(0)
    local res = vim.lsp.buf_request_sync(0, "textDocument/signatureHelp", req)
    log("res:")
    log(res)
    local r = table_first_value(res).result
    if r == nil then
      return
    end
    local st = new_ok_state_available(r)
    if st ~= nil then
      make_state_available(st.help)
    else
      make_state_idle()
    end
  end)
end)

local function do_hl_things()
  for _, hl in pairs(hls) do
    vim.api.nvim_set_hl(namespace, hl.name, hl.default)
  end
end

do_hl_things()

return M
