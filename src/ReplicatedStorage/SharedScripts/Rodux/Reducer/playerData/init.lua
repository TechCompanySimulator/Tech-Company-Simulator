local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local Rodux = loadModule("Rodux")

local combinedReducerTable = {}
for _, module in script:GetChildren() do
	local reducer = require(module)
	combinedReducerTable = Llama.Dictionary.join(combinedReducerTable, reducer)
end

return Rodux.createReducer({}, combinedReducerTable)
