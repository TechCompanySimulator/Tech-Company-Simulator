local function deepClone(dict : table) : table
	local clone = {}

	for k, v in pairs(dict) do
		if type(v) == "table" then
			v = deepClone(v)
		end

		clone[k] = v
	end

	return clone
end

return deepClone