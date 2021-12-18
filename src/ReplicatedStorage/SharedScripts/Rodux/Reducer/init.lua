local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Rodux = loadModule("Rodux")

local Reducers = {}

for _, reducer in pairs(script:GetChildren()) do
	Reducers[reducer.Name] = require(reducer)
end

return Rodux.combineReducers(Reducers)