local function length(dictionary)
	local _length = 0

	for _ in pairs(dictionary) do
		_length += 1
	end

	return _length
end

return length