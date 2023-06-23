local join = require(script.Parent.Dictionary.join)

-- Follows the given path, creating it if it doesn't exist, and returning the endpoint
return function(start, endVal, ...)
	assert(typeof(start) == "table", "Start argument must be a table")

	local path = {...}
	local currentStage = start
	for i, pathName in ipairs(path) do
		currentStage[pathName] = currentStage[pathName] or {}
		if i == #path then
			currentStage[pathName] = if typeof(endVal) == "table" then join(currentStage[pathName], endVal) elseif endVal ~= nil then endVal else {}
		end
		currentStage = currentStage[pathName]
	end

	return currentStage
end