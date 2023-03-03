local function followPath(tab, ...)
	local path = {...}
	local location = tab

	for _, waypoint in ipairs(path) do
		if typeof(location) == "table" then
			location = location[waypoint]
		else
			return nil
		end
	end

	return location
end

return followPath