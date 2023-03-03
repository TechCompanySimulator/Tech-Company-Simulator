local function deepCheckEquality(tab1, tab2)
	assert(typeof(tab1) == "table" and typeof(tab2) == "table", "Cannot compare " .. typeof(tab1) .. " with " .. typeof(tab2))

	for index, value in pairs(tab1) do
		if typeof(value) == "table" and typeof(tab2[index]) == "table" then
			if not deepCheckEquality(value, tab2[index]) then
				return false
			end
		elseif tab2[index] ~= value then
			return false
		end
	end

	for index, value in pairs(tab2) do
		if typeof(value) == "table" and typeof(tab1[index]) == "table" then
			if not deepCheckEquality(value, tab1[index]) then
				return false
			end
		elseif tab1[index] ~= value then
			return false
		end
	end

	return true
end

return deepCheckEquality