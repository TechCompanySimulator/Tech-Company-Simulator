local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Rodux = loadModule("Rodux")
local Table = loadModule("Table")

local GameValues = ReplicatedStorage:WaitForChild("SharedScripts"):WaitForChild("GameValues")

local valuesTable = {}

for _, module in pairs(GameValues:GetChildren()) do
	valuesTable[module.Name] = require(module)
end

return Rodux.createReducer(valuesTable, {
	setGameValues = function(state, action)
		local newTable = action.newTable
		if newTable then
			return Table.clone(newTable)
		end
		return state
	end;
})