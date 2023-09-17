local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local Rodux = loadModule("Rodux")

return Rodux.createReducer({}, {
	addServerMachine = function(state : table, action : table) : table
		local userId = action.userId
		local machine = action.machine
		local guid = machine.machineGUID

		local playerMachines = state[tostring(userId)] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(playerMachines, {
				[tostring(guid)] = machine;
			})
		})
	end;

	removeServerMachine = function(state : table, action : table) : table
		local userId = action.userId
		local machine = action.machine
		local guid = machine.machineGUID

		local playerMachines = state[tostring(userId)] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(playerMachines, {
				[tostring(guid)] = Llama.None;
			})
		})
	end;

	updateServerMachine = function(state : table, action : table) : table
		local userId = action.userId
		local machine = action.machineData
		local guid = machine.machineGUID

		local playerMachines = state[tostring(userId)] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(playerMachines, {
				[tostring(guid)] = machine;
			})
		})
	end;
})