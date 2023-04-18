local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")
local Table = loadModule("Table")

local setGameValues = loadModule("setGameValues")

local GameValues = {
	values = {};
}

-- Adds a value with the given path to the game values table
function GameValues:addValue(value, ...)
	if RunService:IsClient() then return end
	Table.createPath(self.values, value, ...)
	RoduxStore:dispatch(setGameValues(self.values))
end

return GameValues