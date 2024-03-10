local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local Rodux = loadModule("Rodux")

return Rodux.createReducer({}, {
	addServerMachine = function(state: table, action: table): table
		local userId = action.userId
		local machineData = action.machineData
		local guid = machineData.guid

		local playerMachines = state[tostring(userId)] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(playerMachines, {
				[guid] = machineData;
			})
		})
	end;

	updateServerMachine = function(state: table, action: table): table
		local userId = action.userId
		local guid = action.guid
		local newMachineData = action.newMachineData

		local playerMachines = state[tostring(userId)] or {}
		local machineData = playerMachines[guid]

		if not machineData then return state end

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(playerMachines, {
				[guid] = Llama.Dictionary.join(machineData, newMachineData);
			})
		})
	end;

	removeServerMachine = function(state: table, action: table): table
		local userId = action.userId
		local guid = action.guid

		local playerMachines = state[tostring(userId)] or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(playerMachines, {
				[guid] = Llama.None;
			})
		})
	end;

	startServerMachineSession = function(state: table, action: table): table
		local userId = action.userId
		local currentMachineData = state[tostring(userId)] or {}
		local machineData = action.machineData or {}

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.Dictionary.join(currentMachineData, machineData)
		})
	end;

	endServerMachineSession = function(state: table, action: table): table
		local userId = action.userId

		return Llama.Dictionary.join(state, {
			[tostring(userId)] = Llama.None;
		})
	end;
})