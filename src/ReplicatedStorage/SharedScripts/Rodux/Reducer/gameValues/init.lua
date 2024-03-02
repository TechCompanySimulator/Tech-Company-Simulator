local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Rodux = loadModule("Rodux")
local Llama = loadModule("Llama")

local initialValues = {}
for _, module in pairs(script:GetChildren()) do
	initialValues[module.Name] = require(module)
end

return Rodux.createReducer(initialValues, {
	setGameValues = function(state, action)
		local newTable = action.newTable
		if newTable then
			return Llama.Dictionary.copy(newTable)
		end
		
		return state
	end;
})