local M = {}

---@generic T, U
---@param arr T[]
---@param f fun(t: T): U
---@return U[]
local function map(arr, f)
	local res = {}
	for _, v in ipairs(arr) do
		table.insert(res, f(v))
	end
	return res
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

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_signatureHelp

---@class ParameterInformation
---@field label string | integer[]
---@field documentation? string

---@class SignatureInformation
---@field label string
---@field documentation? string
---@field parameters? ParameterInformation[]
---@field activeParameter? integer

---@class SignatureHelp
---@field signatures SignatureInformation[]
---@field activeSignature? integer
---@field activeParameter? integer

---@alias SignatureHelpResponse table<integer, { result: SignatureHelp }>

---@class OkRange
---@field first integer
---@field last integer

---@class OkParameter
---@field label_range OkRange
---@field documentation? string

---@class OkSignature
---@field label string
---@field parameters OkParameter[]
---@field documentation? string

---@class OkStateIdle
---@field kind "idle"

---@class OkStateWaiting
---@field kind "waiting"

---@class OkStateAvailable
---@field kind "available"
---@field signatures OkSignature[]
---@field active_signature_index integer 1-indexed
---@field active_parameter_index integer 1-indexed

---@alias OkState OkStateIdle | OkStateWaiting | OkStateAvailable

---@class HiString
---@field hl_group string
---@field value string

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

---@param si SignatureInformation
---@param pi ParameterInformation
---@return OkParameter
local function new_ok_parameter(si, pi)
	return {
		label_range = new_ok_parameter_label_range(si, pi),
		documentation = pi.documentation,
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
---@return OkSignature
local function new_ok_signature(si)
	return {
		label = si.label,
		parameters = new_ok_parameters(si),
		documentation = si.documentation,
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
		signatures = new_ok_signatures(sh),
		active_signature_index = asi,
		active_parameter_index = api,
	}
end

---@param s OkSignature
---@param p OkParameter
---@return HiString[]
local function ok_parameter_to_hi_strings(s, p)
	return {
		hl_group = "OkSignatureParameter",
		value = string.sub(s.label, p.label_range),
	}
end

vim.keymap.set("n", "<c-k>", function()
	local req = vim.lsp.util.make_position_params(0)
	local res = vim.lsp.buf_request_sync(0, "textDocument/signatureHelp", req)
	vim.notify(vim.inspect(res))
	for _, r in pairs(res) do
		vim.notify(vim.inspect(new_ok_state_available(r.result)))
	end
end)

return M
