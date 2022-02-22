local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")

local setGameValues = loadModule("setGameValues")

local GameValues = {
	values = {};
}

-- Adds a value with the given path to the game values table
function GameValues:addValue(value, ...)
	if RunService:IsClient() then return end
	local path = {...}
	local currentStage = GameValues.values
	for i, pathName in ipairs(path) do
		if not currentStage[pathName] then
			currentStage[pathName] = {}
		end
		if i == #path then
			currentStage[pathName] = value
		else
			currentStage = currentStage[pathName]
		end
	end
	RoduxStore:dispatch(setGameValues(GameValues.values))
end

return GameValues