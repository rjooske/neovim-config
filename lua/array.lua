local M = {}

---@param array any[]
---@param element any
M.contains = function(array, element)
	for _, e in ipairs(array) do
		if e == element then
			return true
		end
	end
	return false
end

return M
