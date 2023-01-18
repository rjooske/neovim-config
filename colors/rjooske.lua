local highlights = {
	{ "DiffAdd", { ctermfg = 2 } },
	{ "DiffChange", { ctermfg = 4 } },
	{ "DiffDelete", { ctermfg = 1 } },
	{ "GitSignsAdd", { link = "DiffAdd" } },
	{ "GitSignsChange", { link = "DiffChange" } },
	{ "GitSignsDelete", { link = "DiffDelete" } },

	{ "DiagnosticHint", { link = "Normal" } },
	{ "DiagnosticInfo", { ctermfg = 6 } },
	{ "WarningMsg", { ctermfg = 3 } },
	{ "DiagnosticWarn", { link = "WarningMsg" } },
	{ "Error", { ctermfg = 9 } },
	{ "ErrorMsg", { link = "Error" } },
	{ "DiagnosticError", { link = "Error" } },

	{ "Pmenu", {} },
	{ "PmenuSel", { standout = true } },

	{ "ColorColumn", { ctermbg = 0 } },

	{ "Whitespace", { ctermfg = 0 } },
	{ "NonText", { link = "Whitespace" } },

	{ "LineNr", { ctermfg = 8 } },
	{ "CursorLineNr", { link = "LineNr" } },
	{ "SignColumn", { link = "Normal" } },

	{ "MatchParen", { ctermbg = 0 } },

	{ "Comment", { ctermfg = 8 } },
	{ "Delimiter", { ctermfg = 7 } },
	{ "Operator", { ctermfg = 3 } },

	{ "Keyword", { ctermfg = 9 } },
	{ "Conditional", { link = "Keyword" } },
	{ "Repeat", { link = "Keyword" } },
	{ "Exception", { link = "Keyword" } },
	{ "@type.qualifier", { link = "Keyword" } },

	{ "Preproc", { link = "Keyword" } },

	{ "Type", { ctermfg = 12 } },
	{ "Typedef", { link = "Type" } },

	{ "Boolean", { ctermfg = 13 } },
	{ "Number", { link = "Boolean" } },
	{ "Float", { link = "Number" } },
	{ "@variable.builtin", { link = "Number" } },
	{ "@storageclass.lifetime", { link = "Number" } },

	{ "String", { ctermfg = 13 } },
	{ "SpecialChar", { ctermfg = 13 } },
	{ "Character", { link = "String" } },

	{ "Constant", { ctermfg = 13 } },

	{ "Identifier", {} },
	{ "@field", { ctermfg = 11 } },
	{ "@property", { ctermfg = 11 } },

	{ "@namespace", { ctermfg = 14 } },

	{ "Function", { ctermfg = 10 } },

	{ "Special", { ctermfg = 14 } },

	{ "@attribute", { ctermfg = 11 } },

	{ "@tag.delimiter", { ctermfg = 8 } },
	{ "@tag.attribute", { link = "@field" } },

	{ "CmpNormal", { bold = true } },
	{ "CmpCursorLine", { standout = true } },
	{ "CmpItemAbbr", { bold = true } },
	{ "CmpItemAbbrMatch", { ctermfg = 2 } },
	{ "CmpItemAbbrMatchFuzzy", { link = "CmpItemAbbrMatch" } },
	{ "CmpItemKindKeyword", { link = "Keyword" } },
	{ "CmpItemKindSnippet", { link = "String" } },
	{ "CmpItemKindFunction", { link = "Function" } },
	{ "CmpItemKindMethod", { link = "Function" } },
	{ "CmpItemKindVariable", { link = "Number" } },
	{ "CmpItemKindConstant", { link = "Number" } },
	{ "CmpItemKindEnumMember", { link = "CmpItemKindVariable" } },
	{ "CmpItemKindField", { link = "@field" } },
	{ "CmpItemKindStruct", { link = "Type" } },
	{ "CmpItemKindClass", { link = "Type" } },
	{ "CmpItemKindInterface", { link = "Type" } },

	{ "LspInfoBorder", { link = "FloatBorder" } },

	{ "LspSignatureActiveParameter", { link = "Visual" } },
}

local setup = function()
	for _, hi in ipairs(highlights) do
		vim.api.nvim_set_hl(0, hi[1], hi[2])
	end
end

setup()
