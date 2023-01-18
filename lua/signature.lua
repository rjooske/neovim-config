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
---@field first integer
---@field last integer

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
		return active.documentation .. "\n" .. params .. "\n" .. table.concat(labels, "\n")
	else
		return params .. "\n" .. table.concat(labels, "\n")
	end
end

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
	vim.notify(text)
end

vim.keymap.set("i", "<c-k>", function()
	log_env(function(log)
		local req = vim.lsp.util.make_position_params(0)
		local res = vim.lsp.buf_request_sync(0, "textDocument/signatureHelp", req)
		log("res:")
		log(res)
		for i, r in pairs(res) do
			local st = new_ok_state_available(r.result)
			log("state " .. i .. ":")
			log(st)
			if st ~= nil then
				log("help " .. i .. ":")
				log(ok_signature_help_to_string(st.help))
				-- for j, sig in ipairs(st.help.signatures) do
				-- 	log("signature #" .. j .. ":")
				-- 	log(ok_signature_to_string(sig))
				-- end
			end
		end
	end)
end)

return M
