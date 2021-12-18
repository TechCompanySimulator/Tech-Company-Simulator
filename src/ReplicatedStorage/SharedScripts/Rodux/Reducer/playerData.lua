local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Rodux = require("Rodux")
local Table = require("Table")

return Rodux.createReducer({}, {
	addPlayerSession = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			return Table.merge(newState, {
				[tostring(userId)] = action.data
			})
		end
		return state
	end;

	removePlayerSession = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			return Table.merge(newState, {
				[tostring(userId)] = Table.None
			})
		end
		return state
	end;

	setPlayerLevel = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			local currentData = newState[tostring(userId)] or {}
			currentData.Level = action.newLevel

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end;

	addMachine = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			local currentData = newState[tostring(userId)]
			currentData.Machines[action.guid] = action.machine

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end;

	removeMachine = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			local currentData = newState[tostring(userId)]
			currentData.Machines[action.guid] = nil

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end;

	setMachineLevel = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			local currentData = newState[tostring(userId)]
			if not currentData.Machines[action.guid] then return state end

			currentData.Machines[action.guid][action.upgradeType .. "Level"] = action.level

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end;

	setMachineOption = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			local currentData = newState[tostring(userId)]
			if not currentData.Machines[action.guid] then return state end

			currentData.Machines[action.guid].buildOption = action.buildOption

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end;

	setMachineAutomation = function(state, action)
		local newState = Table.clone(state)
		local userId = action.userId
		if userId then
			local currentData = newState[tostring(userId)]
			if not currentData.Machines[action.guid] then return state end

			currentData.Machines[action.guid].automation = action.automationEnabled

			return Table.merge(newState, {
				[tostring(userId)] = currentData;
			})
		end
		return state
	end;
})