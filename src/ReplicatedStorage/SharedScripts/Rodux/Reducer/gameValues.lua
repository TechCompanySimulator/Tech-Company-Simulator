local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local Rodux = loadModule("Rodux")

local GameValues = ReplicatedStorage:WaitForChild("SharedScripts"):WaitForChild("GameValues")

local valuesTable = {}

for _, module in GameValues:GetChildren() do
	valuesTable[module.Name] = require(module)
end

return Rodux.createReducer(valuesTable, {
	setGameValues = function(state, action)
		local newTable = action.newTable

		if newTable then
			return Llama.deepClone(newTable)
		end

		return state
	end;
})