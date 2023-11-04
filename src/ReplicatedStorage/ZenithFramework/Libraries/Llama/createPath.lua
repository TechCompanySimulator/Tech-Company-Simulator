local join = require(script.Parent.Dictionary.join)

local function createPath(tab : table, endVal : any, ...) : any
	local path = {...}
	local currentStage = tab

	for ind, waypoint in path do
		currentStage[waypoint] = currentStage[waypoint] or {}

		if ind == #path then
			currentStage[waypoint] = if typeof(endVal) == "table" then join(currentStage[waypoint], endVal) elseif endVal then endVal else {}
		end

		currentStage = currentStage[waypoint]
	end

	return currentStage
end

return createPath
